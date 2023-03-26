
struct ustr{uint16_t buffer[256];};


/*
fbt:nt:ObCreateObjectEx:entry
{
	self->arg = (nt`POBJECT_TYPE) copyin(arg2, sizeof(nt`POBJECT_TYPE));
/*	print(*(struct nt`_OBJECT_TYPE *) self->arg);*/
	
	/*print(self->arg);*/
	self->obj_type = (struct nt`_OBJECT_TYPE *) self->arg;


/*	miniport_addr = arg0 - offsetof(ndis`NDIS_MINIPORT_BLOCK, DevicePowerDownWorkItem);
	miniport = (ndis`NDIS_MINIPORT_BLOCK *)miniport_addr;
*/

	tracemem(self->obj_type, sizeof(nt`_OBJECT_TYPE));
	obj_type_name = (nt`UNICODE_STRING *) &self->obj_type->Name;
	name = alloca(obj_type_name->Length + 2);

	bcopy(obj_type_name->Buffer, name, obj_type_name->Length);
	printf("Object Index %d\n", self->obj_type->Index);
	printf("Object Type Name Length : %d\n",obj_type_name->Length);
	/*printf("Object Type Name: %ws \n", ((struct ustr *)name)->buffer); */



	self->arg9 = args[8];
}


fbt:nt:ObCreateObjectEx:return
{
/*	print(self->arg); 
	print(*(struct nt`_OBJECT_TYPE *) self->arg);
	self->obj_type = (struct nt`_OBJECT_TYPE *) self->arg;
	print(self->obj_type->Name);
	
	printf("Object Name =  %.*ws \n", 
       		self->obj_type->Name.Length / 2, ((struct ustr*)self->obj_type->Name.Buffer)->buffer);
 	
	this->str = *((uintptr_t*)copyin((uintptr_t)self->obj_type->Name.Buffer, self->obj_type->Name.Length));
    	printf("Object Type Name = %s", copyinstr(this->str));
*/
	
	tracemem(self->arg9, sizeof(nt`_OBJECT_HEADER));
}

/*
syscall::NtOpenFile:entry
{
	self->syscall_arg = (nt`POBJECT_ATTRIBUTES) copyin(arg2,sizeof(nt`POBJECT_ATTRIBUTES));

}


syscall::NtOpenFile:return
{
	print(*(struct nt`_OBJECT_ATTRIBUTES *)self->syscall_arg);
 
}*/
