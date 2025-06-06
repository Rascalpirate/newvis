# coding=utf-8

# Compared to original zpp_bits, data_meta is added.
# The usage of data_meta is exactly the same with data_out/in/in_out.
# With the help of meta, data as output can be decoded to txt.
# Moreover, with this python script for zpp, format can be also configured.

import struct
import sys
import os


def getSize(src):
    buf = src.read(4)
    i = struct.unpack("i", buf)[0]
    return i


def convertInt(src, dst):
    i = getSize(src)
    dst.write(str(i) + ",")


def convertBool(src, dst):
    buf = src.read(1)
    if struct.unpack("?", buf)[0]:
        dst.write("True,")
    else:
        dst.write("False,")


def convertDouble(src, dst):
    buf = src.read(8)
    d = struct.unpack("d", buf)[0]
    dst.write(str(d) + ",")


def convertChar(src, dst):
    buf = src.read(1)
    c = struct.unpack("c", buf)[0].decode("utf-8")
    dst.write(c + ",")


def convertStr(src, dst):
    size = getSize(src)
    buf = src.read(size)
    str = struct.unpack("{}s".format(size), buf)[0].decode("utf-8")
    dst.write(str + ",")
    # bstr = struct.unpack("{}c".format(size), buf)
    # str = list()
    # for b in bstr:
    #     str.append(b.decode("utf-8"))

    # dst.write("".join(str) + ',')


def convertFundamental(patternChar, src, dst):
    if patternChar == "i":
        convertInt(src, dst)
    elif patternChar == "c":
        convertChar(src, dst)
    elif patternChar == "s":
        convertStr(src, dst)
    elif patternChar == "d":
        convertDouble(src, dst)
    elif patternChar == "?":
        convertBool(src, dst)
    elif patternChar == "z":
        dst.write("\n")
    elif patternChar == "":
        raise ValueError("The end")
    else:
        raise ValueError("unknown pattern char")


def gotoMatchedBracketInList(metPattern, idx):
    left = 1
    while left > 0 and idx < len(metPattern):
        idx += 1
        patternChar = metPattern[idx]
        if patternChar == "{":
            left += 1
        if patternChar == "}":
            left -= 1

    return idx


def convertInList(src, dst, metPattern, idx):
    patternChar = metPattern[idx]

    if patternChar == "}":
        return idx

    if patternChar == "{":
        size = getSize(src)
        jdx = gotoMatchedBracketInList(metPattern, idx)
        if size == 0:
            return jdx

        # dst.write('\n{\n')
        # dst.write('\n')
        newPattern = metPattern[idx + 1 : jdx]
        for i in range(size):
            mdx = 0
            while mdx < len(newPattern):
                ndx = convertInList(src, dst, newPattern, mdx)
                mdx = ndx + 1

        # dst.write('\n}\n')
        # dst.write('\n')
        return jdx
    else:
        convertFundamental(patternChar, src, dst)

    return idx


def convertWithPatternInList(src, dst, metPattern):
    if len(metPattern) == 0:
        return

    idx = 0
    while idx < len(metPattern):
        jdx = convertInList(src, dst, metPattern, idx)
        idx = jdx + 1


def getNextPatternChar(met):
    return met.read(1)


def gotoMatchedBracket(met):
    left = 1
    while left > 0:
        patternChar = getNextPatternChar(met)
        if patternChar == "{":
            left += 1
        if patternChar == "}":
            left -= 1

    return True


def getMatchedBracket(met):
    left = 1
    pattern = list()
    while left > 0:
        patternChar = getNextPatternChar(met)
        pattern.append(patternChar)
        if patternChar == "{":
            left += 1
        if patternChar == "}":
            left -= 1

    return pattern


def convertWithPattern(patternChar, src, dst, met):
    if patternChar == "}":
        return True

    if patternChar == "{":
        size = getSize(src)
        if size == 0:
            return gotoMatchedBracket(met)

        # dst.write('\n{\n')
        # dst.write('\n')
        if size == 1:
            while True:
                patternChar = getNextPatternChar(met)
                isLastMatchedBracket = convertWithPattern(patternChar, src, dst, met)
                if isLastMatchedBracket:
                    break
        elif size > 1:
            # No need to keep the pattern if no or only one element,
            # Get full pattern directly if more than one element
            # Then convert all the data with the pattern list not the src met
            metPattern = getMatchedBracket(met)

            for i in range(size):
                convertWithPatternInList(src, dst, metPattern)

            # How about each loop mapped to one converter
            # Keep the pattern if outer loops requires the repeatness
            # Leave it a future refactor:
            # while True:
            #     # not pattern, but converter is preferred to
            #     # add converter to converter list so that binary data is converted along the converter
            #     # the creation of converter finishes each time '}' is met
            #     patternChar = getNextPatternChar(met)
            #     isLastMatchedBracket = convertWithPattern(patternChar, src, dst, met)
            #     if isLastMatchedBracket:
            #         break
            #     metPattern.append(patternChar) # should not contain the last '}'

        # dst.write('\n}')
        # dst.write('\n')
    else:
        convertFundamental(patternChar, src, dst)

    return False


def convert(srcDat, dstTxt, srcMet):
    with open(srcDat, "rb") as src, open(dstTxt, "w") as dst, open(srcMet, "r") as met:
        try:
            while True:
                patternChar = getNextPatternChar(met)
                convertWithPattern(patternChar, src, dst, met)

        except ValueError as vale:
            print(vale)
        except EOFError as eofe:
            print(eofe)
        except struct.error as strcte:
            print(strcte)


# Perform os shell command for easier data process
def trimDst(dstZppBFile):
    # os.system("sed -i 's/,\+$//g' {}".format(dstZppBFile))
    # os.system("sed -i 's/,$//g' {}".format(dstZppBFile))
    pass


if "__main__" == __name__:

    # # original: "iiiddd???sss"
    # # formatted with 'z': iiiddd???sssz
    # srcDatZppFile = "plain.dat"

    # # original: "sssiii{i}{i}{i}ddd{ds}{ds}{ds}ccc"
    # # formatted with 'z': sssiiiz{i}z{i}z{i}zdddz{ds}z{ds}z{ds}zcccz
    # srcDatZppFile = "implicit_serialize.dat"

    # # original: "iiiis{s{i}}{s{i}}"
    # # formatted with 'z': iiiisz{s{i}z}{s{i}z}
    # srcDatZppFile = "explicit_serialize.dat"

    # # original: "{sss{s}}"
    # # formatted with 'z': "{sssz{s}}z"
    # srcDatZppFile = "complex_key.dat"

    # # original: "{ssssssss?{sss{s?iddssi}}{s{ss}}{sss{ss}}}"
    # # formatted with 'z': {ssssssss?z{sssz{s?iddssiz}}{sz{ssz}}{sssz{ssz}}}
    # srcDatZppFile = "snapshot_mkup_appdata.dat"

    srcDatZppFile = sys.argv[1]  # *.dat
    print("srcDatZppFile: ", srcDatZppFile)

    srcMetZppFile = sys.argv[2]  # xx.met
    print("srcMetZppFile: ", srcMetZppFile)

    filename, dat = srcDatZppFile.split(".")
    dstTxtZppFile = filename + ".txt"
    print("dstTxtZppFile: ", dstTxtZppFile)

    convert(srcDatZppFile, dstTxtZppFile, srcMetZppFile)

# TODO Geliang:
# Future refactor:
# if there's no {}, keep converting without track the meta info?
# but it's not known whether or not have the pattern in memory, one flag is in need
# The predecent is responsible for set the flag for the converter
# keep reading from met/pattern and converting bi data to txt
# until


def convertE(isPatternReusable):
    pass


def getConverter(patternChar):
    pass


class converter:

    def __init__(self) -> None:
        self.isPatternReusable = False
        self.pattern = ""

    def appendPattern(self, patternChar) -> None:
        self.pattern.append(patternChar)

    def convert(self, patternChar) -> None:
        converter = getConverter(patternChar)
        converter.convert(patternChar)

    def bracketConverter(self):
        if not self.isPatternReusable:
            size = getSize()
            if size > 1:
                self.isPatternReusable = True
        else:
            pass
