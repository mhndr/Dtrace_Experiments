


fbt:nt:ObCreateObjectEx:entry 
{ 
	self->arg2 = (nt`POBJECT_TYPE) copyin(arg2, sizeof(nt`POBJECT_TYPE)); 
	print(self->arg2);
	tracemem(self->arg2, sizeof(struct nt`_OBJECT_TYPE));

	self->arg3 = (nt`POBJECT_ATTRIBUTES) copyin(arg3, sizeof(nt`POBJECT_ATTRIBUTES)); 
	print(self->arg3);
	tracemem(self->arg3, sizeof(struct nt`_OBJECT_ATTRIBUTES));

	self->arg9 = (struct nt`_OBJECT_HEADER*) copyin(arg9, sizeof(struct nt`_OBJECT_HEADER*)); 
	print(*(struct nt`_OBJECT_HEADER*) self->arg9);
	tracemem(self->arg9, sizeof(struct nt`_OBJECT_HEADER));

}


fbt:nt:ObCreateObjectEx:return
{
	self->arg9 = (struct nt`_OBJECT_HEADER*) copyin(arg9, sizeof(struct nt`_OBJECT_HEADER*)); 
	print(self->arg9);
	tracemem(self->arg9, sizeof(struct nt`_OBJECT_HEADER));
}
