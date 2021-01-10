import re
import sys
import json


def sizemap(size):
    if size==1:
        return 'bool'
    elif size<=8:
        return 'uint8_t'
    elif size <=16:
        return 'uint16_t'
    elif size <=32:
        return 'uint32_t'
    else:
        return 'uint64_t'
    

if __name__ == '__main__': 
    RE_START_MODULE = re.compile(r'struct (\S*) : public module {') 
    RE_END_MODULE = re.compile('}; // struct \S*')
    RE_INPUT = re.compile(r'/\*input\*/ value<(\d*)> (\S*).*;')
    RE_OUTPUT = re.compile(r'/\*output\*/ value<(\d*)> (\S*).*;')
    RE_OUTPUTW = re.compile(r'/\*output\*/ wire<(\d*)> (\S*).*;')
    iomap = {}
    inlist = []
    outlist = []
    with open(sys.argv[1], "r") as f:
        cpp = f.read()
        found = None
        for l in cpp.split('\n'):
            if not found:
                found = RE_START_MODULE.findall(l)
                if found:
                    topname = found[0][2:]
                else:
                    continue
            else:
                ifound = RE_INPUT.findall(l)
                if ifound:
                    iname = ifound[0][1][2:]
                    isize = sizemap(int(ifound[0][0]))
                    inlist.append((iname, isize))
                else:
                    ofound = RE_OUTPUT.findall(l)
                    if ofound:
                        oname = ofound[0][1][2:]
                        osize = sizemap(int(ofound[0][0]))
                        outlist.append((oname, osize))
                    else:
                        ofoundw = RE_OUTPUTW.findall(l)
                        if ofoundw:
                            oname = ofoundw[0][1][2:]
                            osize = sizemap(int(ofoundw[0][0]))
                            outlist.append((oname, osize))
                        else:
                            efound = RE_END_MODULE.findall(l)
                            if efound:
                                break
    iomap['name'] = topname
    iomap['inputs'] = inlist
    iomap['outputs'] = outlist
    with open(sys.argv[2], "w") as f:
        json.dump(iomap, f)



