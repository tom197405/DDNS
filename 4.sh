
[[ "$(uname -r | cut -d'.' -f1)" -gt 5 || ( "$(uname -r | cut -d'.' -f1)" -eq 5 && "$(uname -r | cut -d'.' -f2)" -ge 4 ) ]] && echo "yes" || echo "no"
