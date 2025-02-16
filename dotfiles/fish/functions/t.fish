function t --wraps='tmux attach||tmux' --description 'alias t=tmux attach||tmux'
  tmux attach||tmux $argv
        
end
