#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["typer>=0.12", "rich>=13"]
# ///
"""Wgrywa dotfiles z repo do $HOME. Kopiuje tylko pliki, ktore sie roznia."""

import difflib
import filecmp
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Annotated

import typer
from rich.console import Console
from rich.prompt import Prompt
from rich.syntax import Syntax
from rich.table import Table

REPO = Path(__file__).resolve().parent
HOME = Path.home()

# Gdzie w $HOME  <-  skad z repo. Katalog = wszystkie pliki w srodku.
# VS Code celowo pominiety: scalaj recznie ./.config/vscode/merge-settings.sh
MAC = {
    ".tmux.conf": ".tmux.conf",
    ".gitconfig": ".gitconfig",
    ".config/delta": ".config/delta",
    ".config/fish/config.fish": ".config/fish/config.fish",
    ".config/wezterm/wezterm.lua": ".config/wezterm/wezterm.lua",
    ".config/nvim": ".config/nvim",
}
# Stare pliki z ~/.config/fish/functions maja pierwszenstwo przed config.fish
SHADOWING = ["fish_prompt.fish", "fish_right_prompt.fish", "fish_mode_prompt.fish"]

HOMELAB = {
    ".tmux.conf": ".tmux.homelab.conf",
    ".config/nix": ".config/nix",
}

app = typer.Typer(add_completion=False)
console = Console()


@dataclass
class File:
    src: Path
    dst: Path

    @property
    def name(self) -> str:
        return "~/" + str(self.dst.relative_to(HOME))

    @property
    def status(self) -> str:
        if not self.dst.exists():
            return "nowy"
        return "bez zmian" if filecmp.cmp(self.src, self.dst, shallow=False) else "zmieniony"

    @property
    def diff(self) -> list[str]:
        old = self.dst.read_text().splitlines() if self.dst.exists() else []
        new = self.src.read_text().splitlines()
        return list(difflib.unified_diff(old, new, self.name, "repo", lineterm=""))

    @property
    def added(self) -> int:
        return sum(1 for line in self.diff[2:] if line.startswith("+"))

    @property
    def removed(self) -> int:
        return sum(1 for line in self.diff[2:] if line.startswith("-"))


def collect(mapping: dict[str, str]) -> list[File]:
    files = []
    for dst, src in mapping.items():
        src_path = REPO / src
        if src_path.is_dir():
            for f in sorted(src_path.rglob("*")):
                if f.is_file():
                    files.append(File(f, HOME / dst / f.relative_to(src_path)))
        else:
            files.append(File(src_path, HOME / dst))
    return files


def summary(files: list[File]) -> None:
    colors = {"nowy": "green", "zmieniony": "yellow", "bez zmian": "dim"}
    table = Table(title="dotfiles: repo -> $HOME", title_justify="left")
    table.add_column("Plik")
    table.add_column("Status")
    table.add_column("+", justify="right", style="green")
    table.add_column("-", justify="right", style="red")
    for f in files:
        color = colors[f.status]
        if f.status == "bez zmian":
            table.add_row(f.name, f.status, "", "", style=color)
        else:
            table.add_row(f.name, f"[{color}]{f.status}", str(f.added), str(f.removed))
    console.print(table)


@app.command()
def main(
    yes: Annotated[bool, typer.Option("--yes", "-y", help="Kopiuj bez pytania.")] = False,
    dry_run: Annotated[bool, typer.Option("--dry-run", "-n", help="Tylko pokaz, co by sie zmienilo.")] = False,
    diff: Annotated[bool, typer.Option("--diff", "-d", help="Od razu pokaz diff zmienionych plikow.")] = False,
    homelab: Annotated[bool, typer.Option("--homelab", help="Linux/homelab: inny tmux.conf + nix.")] = False,
):
    """Wgrywa dotfiles z repo do $HOME. Kopiuje tylko pliki, ktore sie roznia."""
    files = collect(MAC | HOMELAB if homelab else MAC)
    summary(files)
    for name in SHADOWING:
        if (HOME / ".config/fish/functions" / name).exists():
            console.print(f"[red]Uwaga:[/] ~/.config/fish/functions/{name} cicho nadpisuje prompt z config.fish, usun go")

    changed = [f for f in files if f.status != "bez zmian"]
    if not changed:
        console.print("[green]Wszystko aktualne, nic do skopiowania.")
        return

    if diff:
        show_diff(changed)
    if dry_run:
        return
    while not yes:
        answer = Prompt.ask(f"Skopiowac zmienione pliki ({len(changed)})? [dim](t = tak, n = nie, d = pokaz diff)",
                            choices=["t", "n", "d"], default="t")
        if answer == "n":
            raise typer.Exit(1)
        if answer == "d":
            show_diff(changed)
        else:
            break

    for f in changed:
        f.dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(f.src, f.dst)
    console.print(f"[green]Skopiowano: {len(changed)}")

    if any(".config/fish" in f.name for f in changed):
        console.print("Teraz: [bold]exec fish")
    if any(".config/nvim" in f.name for f in changed):
        console.print("Nvim: zrestartuj, zeby wczytac nowy config")


def show_diff(files: list[File]) -> None:
    for f in files:
        if f.status == "nowy":
            console.print(f"[green]nowy plik: {f.name}")   # caly plik jako diff to tylko szum
        else:
            console.print(Syntax("\n".join(f.diff), "diff", theme="ansi_dark"))


if __name__ == "__main__":
    app()
