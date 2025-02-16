function qq --wraps=gh --wraps='gh copilot suggest' --description 'alias qq gh copilot suggest'
  gh copilot suggest -t shell $argv
end
