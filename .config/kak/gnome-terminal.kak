provide-module gnome-terminal %{
  define-command -hidden gnome-term -params .. -shell-completion -docstring 'Open a new terminal' %{
    nop %sh{
      setsid gnome-terminal "$@" < /dev/null > /dev/null 2>&1 &
    }
  }

  define-command gnome-terminal-popup -params 1.. -shell-completion -docstring 'Open a new terminal as a popup' %{
    gnome-term --class 'gnome-terminal-popup' -- %arg{@}
  }

  define-command gnome-terminal -params 1.. -shell-completion -docstring 'Open a new terminal' %{
    gnome-term -- %arg{@}
  }
}
