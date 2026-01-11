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

dotrc is a git repository containing Gustavo Franco dotrc files and
makesymlinks.

Common usage:

On a fresh macOS system, use bootstrap-my-mac to setup everything:
  https://github.com/stratus/bootstrap-my-mac

Or manually:
$ git clone git@github.com:stratus/dotrc.git
$ cd dotrc
$ ./makesymlinks

It will create the necessary symlinks from ~/.<rc_file> to
~/dotrc/rcs/<rc_file>

Note: macos-cli-setup.sh has been removed. Use bootstrap-my-mac instead
for complete system setup (Homebrew, tools, vim, tmux, etc.)
