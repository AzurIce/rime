link:
  rm -rf ~/Library/Rime/dicts
  ln -s ~/.dotfiles/rime/dicts ~/Library/Rime/dicts

  rm -f ~/Library/Rime/default.custom.yaml
  rm -f ~/Library/Rime/luna_pinyin.custom.yaml
  rm -f ~/Library/Rime/luna_pinyin.extended.dict.yaml
  ln -s ~/.dotfiles/rime/default.custom.yaml ~/Library/Rime/default.custom.yaml
  ln -s ~/.dotfiles/rime/luna_pinyin.custom.yaml ~/Library/Rime/luna_pinyin.custom.yaml
  ln -s ~/.dotfiles/rime/luna_pinyin.extended.dict.yaml ~/Library/Rime/luna_pinyin.extended.dict.yaml

submodule:
  git submodule update --init --recursive

gen-rime-symbols:
  mkdir -p dicts
  mkdir -p cache/opencc
  cd cache/opencc && ../../submodules/rime-symbols/rime-symbols-gen
  cd cache && cat ../submodules/rime-emoji/opencc/*.txt opencc/*.txt | opencc -c t2s.json | uniq > ../dicts/symbols.txt

gen-dicts: gen-rime-symbols
  python scripts/clover-dict-gen.py
  python scripts/thuocl2rime.py
