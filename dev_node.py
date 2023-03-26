

"""
    struct _DEVICE_NODE *Sibling = 0
    struct _DEVICE_NODE *Child = 0xffffd58bbf9cbb00
    struct _DEVICE_NODE *Parent = 0
    struct _DEVICE_NODE *LastChild = 0xffffd58be1a6d010
    struct _DEVICE_OBJECT *PhysicalDeviceObject = 0xffffd58bbf86fdf0
    struct _UNICODE_STRING InstancePath = {
        UInt16 Length = 0x18
        UInt16 MaximumLength = 0x1a
        wchar_t *Buffer = 0xffffd58bbf886930
    }
    struct _UNICODE_STRING ServiceName = {
        UInt16 Length = 0
        UInt16 MaximumLength = 0
        wchar_t *Buffer = 0
    }
"""



import subprocess

def get_unicode_str_from_ptr(addr,size):
    if size == "0" or addr == "0":
        return  " "
    cmd = 'dtrace -n \"BEGIN{tracemem(%s,%s);exit(0);}\" '%(addr,size)
    child_proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    line = child_proc.stdout.readline().decode().strip()
    
    while line and "0123456789abcdef" not in line: 
        line = child_proc.stdout.readline().decode().strip()
    
    output = ""
    line = child_proc.stdout.readline().decode().strip() 
    while line:
        output += line.split()[-1]
        line = child_proc.stdout.readline().decode().strip() 
    output = output.replace('.','')
    return output
    
    

def print_all_unicode_strings(data, indent=0,given_variable = None):
    if not data:
        return 
    lines = []
    for i,line in enumerate(data): 
        if "_UNICODE_STRING" in line:
            variable = line.split()[2]
            if given_variable and given_variable != variable:
                continue
            length = data[i+1].split()[-1] 
            buffer_addr = data[i+3].split()[-1]
            ret = get_unicode_str_from_ptr(buffer_addr,length)
            if len(ret.strip()) != 0:
                out = variable+" = "+ret
                for i in range(indent):
                    out = " "+out
                print(out)
                if given_variable:
                    return
    print("\n")
    return
   
"""
    enum _PNP_DEVNODE_STATE State = DeviceNodeStarted
    enum _PNP_DEVNODE_STATE PreviousState = DeviceNodeEnumerateCompletion
"""
def print_variable(data,variable,indent=0):
    if not data or not variable:
        return
    for line in data:
        if variable in line:
            print(line)
            fields = line.split()
            out = fields[fields.index(variable):]
            for i in range(indent):
                out = " "+out
            print(out)
            return



def print_all_device_nodes(node_addr="nt`IopRootDeviceNode",indent=0):
    cmd = 'dtrace -n \"BEGIN{print(*(struct nt`_DEVICE_NODE *)%s);exit(0);}\" '%(node_addr)
    #cmd = 'dtrace -n \"BEGIN{print(*(struct nt`_DEVICE_NODE *)nt`IopRootDeviceNode);exit(0);}\" -y \"c:\symbols\"'
    child_proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    data = []
    data = child_proc.stdout.read().decode().strip().splitlines()

    #print this node's name, path info and any other strings
    #print_all_unicode_strings(data,indent)
    print_all_unicode_strings(data,indent,"InstancePath")
    #print_all_unicode_strings(data,indent,"ServiceName")
    #print_variable(data,"\ State =\ ",indent)


    #process children and siblings
    child = None
    sibling = None
    for i,line in enumerate(data):
        if "*Child = " in line:
            fields = line.split()
            if fields[-1] != '0':
                child = fields[-1]
        if "*Sibling = " in line:
            fields = line.split()
            if fields[-1] != '0':
                sibling = fields[-1]
    if child:
        print_all_device_nodes(child,indent+4)
    if sibling:
        print_all_device_nodes(sibling,indent)
    return
  



if __name__ == "__main__":
    print_all_device_nodes()




