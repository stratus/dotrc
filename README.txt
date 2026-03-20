Copyright (C) 2024 Gustavo Franco <stratus@acm.org>.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License

dotrc
=====

A git repository containing Gustavo Franco's dotfiles and a symlink
installer. Managed config files:

  .bash_profile    - Login shell: Homebrew, macchina, PATH setup
  .bashrc          - Interactive shell: aliases (eza, bat, htop, rg),
                     fzf, direnv
  .gitconfig       - Git settings
  .screenrc        - GNU Screen configuration
  .tmux.conf.local - tmux overrides (gpakosz/.tmux framework)
  .tmux-layout.sh  - tmux layout helper script

Prerequisites
-------------

  - Python 3
  - Git (for tmux config bootstrap)
  - macOS with Homebrew (for full functionality)

Optional CLI tools used in .bashrc aliases:

  - eza (aliased as ls)
  - bat (aliased as cat)
  - htop (aliased as top)
  - ripgrep / rg (aliased as grep)
  - fzf (fuzzy finder)
  - direnv (per-directory environment)
  - macchina (system info on shell login)
  - tmux (terminal multiplexer, config from gpakosz/.tmux)
  - git (required for tmux config bootstrap)

Install optional tools via Homebrew: brew install eza bat htop ripgrep fzf direnv macchina tmux

Quick Start
-----------

  $ git clone https://github.com/stratus/dotrc.git
  $ cd dotrc
  $ ./makesymlinks

Then reload your shell:

  $ exec bash -l

How makesymlinks Works
----------------------

On first run, the script bootstraps tmux by cloning gpakosz/.tmux
into ~/.tmux and symlinking ~/.tmux.conf to the upstream config.
Your local overrides (.tmux.conf.local) are then symlinked from rcs/
as with any other dotfile. To update the upstream tmux config later:

  $ cd ~/.tmux && git pull

The script then walks through rcs/ and for each regular file:

  1. If ~/.<file> is already a symlink — skips it
  2. If ~/.<file> is a directory — skips it
  3. If ~/.<file> exists as a regular file — renames it to <file>.bak
  4. Creates a symlink: ~/.<file> -> dotrc/rcs/<file>

Set RCS_PATH to override the source directory:

  $ RCS_PATH=/path/to/custom/rcs ./makesymlinks

Enable debug logging:

  Edit makesymlinks and set DEBUG = True

Development
-----------

Pre-commit hooks are configured. To set up:

  $ pip install pre-commit   # or: pipx install pre-commit
  $ pre-commit install

Hooks run on commit: trailing whitespace, end-of-file fixer,
YAML validation, shellcheck.

Run tests:

  $ python3 -m pytest test_makesymlinks.py -v
