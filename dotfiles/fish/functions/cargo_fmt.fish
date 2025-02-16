function cargo_fmt --wraps='cargo clippy --fix && cargo fmt' --description 'alias cargo_fmt=cargo clippy --fix && cargo fmt'
  cargo clippy --fix && cargo fmt $argv
        
end
