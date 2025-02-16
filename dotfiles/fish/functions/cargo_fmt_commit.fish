function cargo_fmt_commit --wraps=cargo\ clippy\ --fix\ \&\&\ cargo\ fmt\ \&\&\ git\ add\ -A\ \&\&\ git\ commit\ -m\ \'cargo\ clippy\ --fix\ \&\&\ cargo\ fmt\' --description alias\ cargo_fmt_commit=cargo\ clippy\ --fix\ \&\&\ cargo\ fmt\ \&\&\ git\ add\ -A\ \&\&\ git\ commit\ -m\ \'cargo\ clippy\ --fix\ \&\&\ cargo\ fmt\'
  cargo clippy --fix && cargo fmt && git add -A && git commit -m 'refactor: cargo clippy --fix && cargo fmt' $argv

end
