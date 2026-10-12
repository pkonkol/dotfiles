#!/usr/bin/env -S npx --yes zx@8
// Wgrywa dotfiles z repo do $HOME. Kopiuje tylko pliki, ktore sie roznia.
// To samo co deploy.py, wersja zx do porownania. Tylko to, co zx ma wbudowane
// ($, fs, path, glob, chalk, argv, question, echo) + git do liczenia diffu.
const REPO = import.meta.dirname
const HOME = os.homedir()

// Gdzie w $HOME  <-  skad z repo. Katalog = wszystkie pliki w srodku.
// VS Code celowo pominiety: scalaj recznie ./.config/vscode/merge-settings.sh
const MAC = {
  '.tmux.conf': '.tmux.conf',
  '.gitconfig': '.gitconfig',
  '.gitconfig-personal': '.gitconfig-personal',
  '.config/delta': '.config/delta',
  '.config/bat': '.config/bat',
  '.config/fish/config.fish': '.config/fish/config.fish',
  '.config/wezterm/wezterm.lua': '.config/wezterm/wezterm.lua',
  '.config/nvim': '.config/nvim',
}
const HOMELAB = {
  '.tmux.conf': '.tmux.homelab.conf',
  '.config/nix': '.config/nix',
}
// Stare pliki z ~/.config/fish/functions maja pierwszenstwo przed config.fish
const SHADOWING = ['fish_prompt.fish', 'fish_right_prompt.fish', 'fish_mode_prompt.fish']

const opts = minimist(process.argv.slice(3), {
  boolean: ['yes', 'dry-run', 'diff', 'homelab', 'help'],
  alias: { y: 'yes', n: 'dry-run', d: 'diff', h: 'help' },
})
if (opts.help) {
  echo(`Uzycie: deploy.mjs [opcje]
  -y, --yes       kopiuj bez pytania
  -n, --dry-run   tylko pokaz, co by sie zmienilo
  -d, --diff      od razu pokaz diff zmienionych plikow
      --homelab   Linux/homelab: inny tmux.conf + nix`)
  process.exit(0)
}

async function collect(mapping) {
  const files = []
  for (const [dst, src] of Object.entries(mapping)) {
    const srcPath = path.join(REPO, src)
    const inside = (await fs.stat(srcPath)).isDirectory()
      ? (await glob('**', { cwd: srcPath, dot: true })).sort()
      : ['']
    for (const rel of inside) files.push(await check(path.join(srcPath, rel), path.join(HOME, dst, rel)))
  }
  return files
}

async function check(src, dst) {
  const name = '~/' + path.relative(HOME, dst)
  const exists = await fs.pathExists(dst)
  // git diff --numstat wypisuje: "<dodane>\t<usuniete>\t<plik>"; /dev/null = plik jeszcze nie istnieje
  const numstat = await $`git diff --no-index --numstat ${exists ? dst : '/dev/null'} ${src}`.nothrow()
  const [added = 0, removed = 0] = numstat.stdout.split('\t').map(Number)
  const status = !exists ? 'nowy' : numstat.stdout === '' ? 'bez zmian' : 'zmieniony'
  return { src, dst, name, status, added, removed }
}

function summary(files) {
  const color = { nowy: chalk.green, zmieniony: chalk.yellow, 'bez zmian': chalk.dim }
  const width = Math.max(...files.map((f) => f.name.length))
  echo(chalk.bold(`${'Plik'.padEnd(width)}  ${'Status'.padEnd(9)}  ${'+'.padStart(5)}  ${'-'.padStart(5)}`))
  for (const f of files) {
    const c = color[f.status]
    const [plus, minus] = f.status === 'bez zmian' ? ['', ''] : [f.added, f.removed]
    echo(`${f.name.padEnd(width)}  ${c(f.status.padEnd(9))}  ${chalk.green(String(plus).padStart(5))}  ${chalk.red(String(minus).padStart(5))}`)
  }
}

async function showDiff(files) {
  for (const f of files) {
    if (f.status === 'nowy') echo(chalk.green(`nowy plik: ${f.name}`))
    else await $({ stdio: 'inherit', nothrow: true })`git --no-pager diff --no-index --color ${f.dst} ${f.src}`
  }
}

const files = await collect(opts.homelab ? { ...MAC, ...HOMELAB } : MAC)
summary(files)
for (const name of SHADOWING) {
  if (await fs.pathExists(path.join(HOME, '.config/fish/functions', name)))
    echo(`${chalk.red('Uwaga:')} ~/.config/fish/functions/${name} cicho nadpisuje prompt z config.fish, usun go`)
}

const changed = files.filter((f) => f.status !== 'bez zmian')
if (changed.length === 0) {
  echo(chalk.green('Wszystko aktualne, nic do skopiowania.'))
  process.exit(0)
}
if (opts.diff) await showDiff(changed)
if (opts['dry-run']) process.exit(0)

while (!opts.yes) {
  const answer = await question(`Skopiowac zmienione pliki (${changed.length})? ${chalk.dim('(t = tak, n = nie, d = pokaz diff)')} [t/n/d] (t): `)
  if (answer === 'n') process.exit(1)
  if (answer === 'd') await showDiff(changed)
  if (answer === 't' || answer === '') break
}

for (const f of changed) await fs.copy(f.src, f.dst)   // fs-extra: sam tworzy katalogi
echo(chalk.green(`Skopiowano: ${changed.length}`))

if (changed.some((f) => f.name.includes('.config/bat')) && (await which('bat', { nothrow: true })))
  await $`bat cache --build`                          // bat czyta motywy tylko z cache
if (changed.some((f) => f.name.includes('.config/fish'))) echo(`Teraz: ${chalk.bold('exec fish')}`)
if (changed.some((f) => f.name.includes('.config/nvim'))) echo('Nvim: zrestartuj, zeby wczytac nowy config')
