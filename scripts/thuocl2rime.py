#!/usr/bin/env python
#-*- encoding:utf-8 -*-

import pypinyin

import argparse
import os
import sys

initials_set = set(pypinyin.style._constants._INITIALS)   # 声母表

def main(src, dst):
    if not os.path.isfile(src):
        sys.stderr.out("文件 %s 不存在。" % src)
        return 1

    if dst is None:
        file_name = src[src.rfind(os.sep)+1:]
        dot_pos = file_name.rfind('.')
        if dot_pos == -1:
            dst = file_name + '.dict.yaml'
        else:
            dst = file_name[:dot_pos] + '.dict.yaml'

    if not dst.endswith('.dict.yaml'):
        sys.stderr.out("目标文件需要以 .dict.yaml 结尾")
        return 2
    name = dst[dst.rfind(os.sep)+1:][:-10]

    result = """name: %s
version: "1"
sort: by_weight

...
""" % name

    # 检查每个字都为合法汉字的字符串
    def checkPhrase(phrase):
        for c in phrase:
            if ord(c) not in pypinyin.pinyin_dict.pinyin_dict:
                return False
        return True

    text = open(src).read()
    for v in map(lambda x:x.split(), text.split('\n')):
        if len(v) == 2:
            # 检查该词组的每个字必须为汉字
            if not checkPhrase(v[0]):
                continue

            # 获取该词组的拼音
            pinyin = pypinyin.lazy_pinyin(v[0])
            for p in pinyin:
                if p in initials_set:  # 拼音不能只包含声母
                    break
            else:
                result += v[0] + '\t' + ' '.join(pinyin) + '\t' + v[1] + '\n'

    open(dst, 'w').write(result)
    return 0

if __name__ == '__main__':
    current_dir = os.path.dirname(os.path.abspath(__file__))
    thuocl_data_dir = os.path.join(current_dir, '..', 'submodules', 'THUOCL', 'data')
    dicts_dir = os.path.join(current_dir, '..', 'dicts')

    for filename in os.listdir(thuocl_data_dir):
        src = os.path.normpath(os.path.join(thuocl_data_dir, filename))
        dst = os.path.normpath(os.path.join(dicts_dir, os.path.splitext(filename)[0] + ".dict.yaml"))
        print(f'converting {os.path.relpath(src)} to {os.path.relpath(dst)}...')
        main(src, dst)

    # parser = argparse.ArgumentParser(description = \
    #     "将清华大学开放中文词库转换为 rime 的词库格式 .dict.yaml")
    # parser.add_argument('src', help = \
    #     '清华大学开放中文词库文件，一般形如 THUOCL_xx.txt')
    # parser.add_argument('dest', help = \
    #     '目标文件路径，注意要以 .dict.yaml 结尾，' + \
    #     '如果此参数省略，则会在当前目录下生成同名的 .dict.yaml 文件。',
    #     nargs='?')

    # args = parser.parse_args()

    # exit(main(args))
