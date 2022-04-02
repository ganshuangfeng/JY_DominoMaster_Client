# encoding:utf-8

import argparse
import sys
import getopt
import os
import io
import tinify
import time
import inspect

os.environ['REQUESTS_CA_BUNDLE'] =  os.path.join(os.path.dirname(sys.argv[0]), 'cacert.pem')

parser = argparse.ArgumentParser(prog="WriteJSON", description="Writing the input json data to the Corresponding.")

parser.add_argument("-k", "--server_key", default="kc041FrHMm3vMbdZfLqcfGrJX0ynmYbq", help="tinypng server key!")
parser.add_argument("-i", "--input_file", default="", help="input png path!")
parser.add_argument("-r", "--root_path", default="", help="root_path!")
parser.add_argument("-x", "--shield_path", default="tinypng_shield.txt", help="shield_path!")
parser.add_argument("-t", "--compress_type", default="1", help="compress_type")
parser.add_argument("-version", action="version", version="%(prog)s 1.0")
args = parser.parse_args()

division = '========================'

input_files = []
shield_files = {} # 屏蔽库
cache_files = {} # 缓存库 记录压缩过的图 第二次就对比size

class CompressData:
    def __init__(self, data):
        self.server_key = data.server_key
        self.input_file = data.input_file
        self.root_path = data.root_path
        self.shield_path = data.shield_path
        self.compress_type = data.compress_type

data = CompressData(args)

def getAllImage(folderPath, imageList):
    extend_name = ["jpg","jpeg","png"]
    if os.path.isfile(folderPath):
        if folderPath.split('.')[-1] in extend_name:
            imageList.append(folderPath)
            return imageList
    for item in os.listdir(folderPath):
        if os.path.isdir(os.path.join(folderPath,item)):
            subFolderPath = os.path.join(folderPath, item)
            getAllImage(subFolderPath, imageList)
        else:
            filePath = os.path.join(folderPath,item)
            if os.path.isfile(filePath):
                if item.split('.')[-1] in extend_name:
                    imageList.append(filePath)
    return imageList

def compressPng(argv):
    print("        <<<<<<<<< start compress")
    start = time.perf_counter()
    scale = 50
    inlen = len(input_files)

    all_size = 0
    cur_size = 0
    for i, input_file in enumerate(input_files):
        j = i + 1
        k = int(j/inlen*scale)
        a = "*" * (k)
        b = "." * (scale - k)
        c = (j / inlen) * 100
        dur = time.perf_counter() - start

        image = open(input_file, 'rb').read()
        image_b = io.BytesIO(image).read()
        all_size = all_size + len(image_b)
        name = input_file.split('\\')[-1]

        if argv.compress_type == "1":
            tiny_file(argv.server_key, input_file)
        image = open(input_file, 'rb').read()
        image_b = io.BytesIO(image).read()
        cur_size = cur_size + len(image_b)
        print("\r {:^3.0f}%[{}->{}]{:.2f}s {}/{} size:{:.1f}/{:.1f}({:.2f}%)".format( c,a,b,dur,j,inlen, cur_size/1024,all_size/1024,(100*(all_size-cur_size)/all_size)),end = "")

    print("\n        <<<<<<<<< end compress")
    print("\n 如果压缩没有生效请检查cacert.pem文件是否存在。\n")


def tiny_file(server_key, in_file):
    try:
        tinify.key = server_key
        tinify.from_file(in_file).to_file(in_file)
    except:
        pass
    else:
        global cache_files
        global data
        image = open(in_file, 'rb').read()
        image_b = io.BytesIO(image).read()
        in_kk = in_file[len(data.root_path):]
        cache_files[in_kk] = len(image_b)

def runCall():
    global data
    if data.compress_type == "1":
        compressPng(data)
    else:
        print("non-existent compress_type=" + data.compress_type)

def readShield(shield_path):
    global shield_files
    global cache_files
    shield_files = {}
    cache_files = {}
    if os.path.exists(shield_path):
        with open(shield_path, "r", encoding='utf-8') as f:
            stage = 1
            kk = ""
            ss = 0
            ii = 0
            for line in f.readlines():
                line = line.strip('\n')  #去掉列表中每一个元素的换行符
                if len(line) > 0:
                    if division == line:
                        stage = 2
                    else:
                        if stage == 1:
                            shield_files[line] = 1
                        else:
                            if ii%2 == 0:
                                kk = line
                            else:
                                ss = line
                                # 判断是否是数字
                                cache_files[kk] = ss
                            ii=ii+1

def saveCacheFile(shield_path, shield_files, cache_files):
    fd = open(shield_path, 'w', encoding='utf-8')
    for key in shield_files:
        fd.write(str(shield_files[key])+'\n')
    fd.write(division+'\n')
    for key in cache_files:
        fd.write(key+'\n')
        fd.write(str(cache_files[key])+'\n')
    fd.close()
    
if __name__ == '__main__':
    n = 1
    if not data.root_path:
        data.root_path = input("root_path(exit):")
    if data.root_path == 'exit':
        n = -1

    while n > 0:
        if not data.input_file:
            data.input_file = input("input_file(exit):")
        elif data.input_file == 'exit':
            n = -1
        else:
            if not os.path.exists(data.input_file):
                print("file/dir not exists")
                data.input_file = None
            else:
                input_files = []
                getAllImage(data.input_file, input_files)
                if not input_files or len(input_files) < 1:
                    print("png/jpg... null")
                else:
                    maxLen = len(input_files)
                    root_path = data.root_path
                    readShield(data.shield_path)
                    buf_input_files = []
                    for i, ifile in enumerate(input_files):
                        if ifile.find(root_path) >= 0:
                            lpath = ifile[len(root_path):]
                            isnot = 1
                            for key in shield_files:
                                if ifile.find(key) >= 0:
                                    isnot = 0
                                    break
                            if isnot == 1:
                                if cache_files.__contains__(lpath):
                                    image = open(ifile, 'rb').read()
                                    image_b = io.BytesIO(image).read()
                                    if len(image_b) > (int)(cache_files[lpath]):
                                        buf_input_files.append(ifile)
                                else:
                                    buf_input_files.append(ifile)
                        else:
                            buf_input_files.append(ifile)
                    print("\n===========================")
                    input_files = buf_input_files
                    if not input_files or len(input_files) < 1:
                        print("     {} png/jpg file all not compress !".format(maxLen))
                    else:
                        b = input("png/jpg all count = ( {} ) zip count = ( {} ) Continue?(Y/N):".format(maxLen, len(input_files)))
                        if b == 'Y' or b == 'y':
                            runCall()
                            saveCacheFile(data.shield_path, shield_files, cache_files)
                    data.input_file = None

os.system("pause")
# pyinstaller -F TinyPng.py

# 加一个屏蔽列表 需要参数：root目录（为了多人使用），[屏蔽文件]目录(或文件)列表
# 例如:root=E:\1_word_HuanLe\HuanLe_client\1_code\ 
# 例如:root=E:\1_word_HuanLe\HuanLe_client_release\1_code\ 
# 这两个目录不一样但是是同一个工程的不同分支，所以会使用同一份[屏蔽文件]


