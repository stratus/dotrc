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

  .bash_profile  - Login shell: Homebrew, macchina, PATH setup
  .bashrc        - Interactive shell: aliases (eza, bat, htop, rg),
                   fzf, direnv
  .gitconfig     - Git settings
  .screenrc      - GNU Screen configuration

Prerequisites
-------------

  - Python 3
  - macOS with Homebrew (for full functionality)

Optional CLI tools used in .bashrc aliases:

  - eza (aliased as ls)
  - bat (aliased as cat)
  - htop (aliased as top)
  - ripgrep / rg (aliased as grep)
  - fzf (fuzzy finder)
  - direnv (per-directory environment)
  - macchina (system info on shell login)

Install all optional tools via bootstrap-my-mac (see below).

Quick Start
-----------

On a fresh macOS system, use bootstrap-my-mac for complete setup:
  https://github.com/stratus/bootstrap-my-mac

Or manually:

  $ git clone git@github.com:stratus/dotrc.git
  $ cd dotrc
  $ ./makesymlinks

Then reload your shell:

  $ exec bash -l

How makesymlinks Works
----------------------

The script walks through rcs/ and for each regular file:

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

Note: macos-cli-setup.sh has been removed. Use bootstrap-my-mac
instead for complete system setup (Homebrew, tools, vim, tmux, etc.)
