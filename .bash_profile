# Add `~/bin` and ruby user-gems to the `$PATH`. Ruby 3.2.x → gem API dir is "3.2.0".
export PATH="$HOME/bin:$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH";

# Per-machine tool paths — gated with -d so a machine missing the tool silently skips
# it (these dotfiles are shared across jolly/tigerpaw; not every tool is on every box).
# Foundry (EVM)
[ -d "$HOME/.foundry/bin" ] && export PATH="$HOME/.foundry/bin:$PATH";
# Solana CLI
[ -d "$HOME/.local/share/solana/install/active_release/bin" ] && export PATH="$PATH:$HOME/.local/share/solana/install/active_release/bin";
# Codex
[ -d "/Applications/Codex.app/Contents/Resources" ] && export PATH="$PATH:/Applications/Codex.app/Contents/Resources";
# Bun
[ -d "$HOME/.bun/bin" ] && export PATH="$PATH:$HOME/.bun/bin";
# gcloud SDK
[ -d "$HOME/Projects/clients/gcli/google-cloud-sdk/bin" ] && export PATH="$PATH:$HOME/Projects/clients/gcli/google-cloud-sdk/bin";

# local bin
export PATH="$PATH:$HOME/.local/bin";


# Add homebrew path
if [ "${SHELL}" = "/opt/homebrew/bin/bash" ]; then
  export PATH="$HOME/bin:/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.2.0/bin:$PATH";
  eval "$(/opt/homebrew/bin/brew shellenv)";
else
  export PATH="$HOME/bin:/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/3.2.0/bin:$PATH";
  eval "$(/usr/local/bin/brew shellenv)";
fi;

# 21/Oct/2025 Add chruby config for jekyll
source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
source $(brew --prefix)/opt/chruby/share/chruby/auto.sh
chruby ruby-3.2.2

# Starting on macOS Catalina (10.15) the headers used for Ruby have been moved
# from their previous location which results in some gems, including Jekyll to
# fail installation. This can be solved by setting SDKROOT in your shell
# configuration to the value provided by xcrun.
export SDKROOT=$(xcrun --show-sdk-path)

# Suppress the "The default interactive shell is now zsh." OSX message
export BASH_SILENCE_DEPRECATION_WARNING=1

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
	source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi


# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f ~/.git-completion.bash ]; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

# Move next only if `homebrew` is installed
if command -v brew >/dev/null 2>&1; then
	# Load rupa's z if installed
	[ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
fi

# Load NVM last, after every other PATH mutation above (Homebrew's shellenv,
# chruby, RVM, ~/.path, brew bash_completion, z) — nvm prepends its own bin
# dir, so sourcing it last guarantees nvm's node always wins on PATH instead
# of a Homebrew-installed node silently shadowing it.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
