#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["json5>=0.9", "pydantic>=2", "typer>=0.12"]
# ///
"""Scala fragmenty settings/*.jsonc do settings.json wybranych profili VS Code.

Klucze z fragmentow nadpisuja istniejace, reszta ustawien profilu zostaje.
Klucz usuniety z fragmentu NIE znika z profilu — usun go recznie.
Komentarze z settings.json profilu nie przetrwaja zapisu; zostaja w backupie.
"""

import json
import shutil
from datetime import datetime
from pathlib import Path
from typing import Annotated

import json5
import typer
from pydantic import BaseModel

FRAGMENTS_DIR = Path(__file__).resolve().parent / "settings"
VSCODE_USER_DIR = Path.home() / "Library/Application Support/Code/User"
DEFAULT_PROFILE = "Default"

app = typer.Typer(add_completion=False)


class SharedWithDefault(BaseModel):
    settings: bool = False  # VS Code pomija pole, gdy profil ma wlasne ustawienia


class Profile(BaseModel):
    name: str
    location: str
    useDefaultFlags: SharedWithDefault = SharedWithDefault()


class Storage(BaseModel):
    userDataProfiles: list[Profile]


def load_fragments() -> dict:
    merged = {}
    for fragment in sorted(FRAGMENTS_DIR.glob("*.jsonc")):
        merged.update(json5.loads(fragment.read_text()))
    return merged


def profile_settings_path(profile_name: str) -> Path:
    if profile_name == DEFAULT_PROFILE:
        return VSCODE_USER_DIR / "settings.json"
    storage = Storage.model_validate_json(
        (VSCODE_USER_DIR / "globalStorage/storage.json").read_text()
    )
    profiles = {profile.name: profile for profile in storage.userDataProfiles}
    if profile_name not in profiles:
        known = ", ".join([DEFAULT_PROFILE, *profiles])
        raise typer.BadParameter(f"brak profilu {profile_name!r}; sa: {known}")
    profile = profiles[profile_name]
    if profile.useDefaultFlags.settings:
        raise typer.BadParameter(
            f"profil {profile_name!r} uzywa ustawien z {DEFAULT_PROFILE}, scal do {DEFAULT_PROFILE}"
        )
    return VSCODE_USER_DIR / "profiles" / profile.location / "settings.json"


def merge_into(profile_name: str, target: Path, fragments: dict, dry_run: bool) -> None:
    current_text = target.read_text() if target.exists() else "{}"
    current = json5.loads(current_text)
    added = [key for key in fragments if key not in current]
    changed = [
        key for key in fragments if key in current and current[key] != fragments[key]
    ]

    typer.echo(f"\n{profile_name}: {target}")
    for key in added:
        typer.echo(f"  + {key}")
    for key in changed:
        typer.echo(f"  ~ {key}")
    if not (added or changed):
        typer.echo("  bez zmian")
        return
    if dry_run:
        return

    if target.exists():
        backup = target.with_name(
            f"settings.json.bak.{datetime.now().astimezone():%Y%m%d-%H%M%S}"
        )
        shutil.copy2(target, backup)
        typer.echo(f"  backup: {backup}")
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        json.dumps(current | fragments, indent=2, ensure_ascii=False) + "\n"
    )
    typer.echo(f"  dodane: {len(added)}, nadpisane: {len(changed)}")


@app.command()
def main(
    profiles: Annotated[
        list[str],
        typer.Argument(
            help=f"Nazwy profili VS Code, np. {DEFAULT_PROFILE} dotfiles aiboostr."
        ),
    ],
    dry_run: Annotated[
        bool, typer.Option("--dry-run", "-n", help="Tylko pokaz, co by sie zmienilo.")
    ] = False,
):
    """Scala fragmenty settings/*.jsonc do settings.json wybranych profili VS Code."""
    fragments = load_fragments()
    targets = {
        profile_name: profile_settings_path(profile_name) for profile_name in profiles
    }
    for profile_name, target in targets.items():
        merge_into(profile_name, target, fragments, dry_run)


if __name__ == "__main__":
    app()
