
struct ustr{uint16_t buffer[256];};


fbt:nt:ObCreateObjectEx:entry
{
	/*print(arg2); */
	if(arg2 != 0)  
	{
		self->arg = (nt`_OBJECT_TYPE *) copyin(arg2, sizeof(nt`_OBJECT_TYPE));
		if(self->arg) {
			/*print(*(struct nt`_OBJECT_TYPE *)self->arg); */
			self->obj_type = (struct nt`_OBJECT_TYPE *) self->arg;
			obj_type_name = (nt`UNICODE_STRING *) &self->obj_type->Name;
			
			if(obj_type_name->Length != 0)
			{
				name = alloca(obj_type_name->Length + 2);
				bcopy(obj_type_name->Buffer, name, obj_type_name->Length);
				printf("Object Type Name: %ws \n", ((struct ustr *)name)->buffer); 
			}
			else
			{
				printf("unicode string length is 0");
			}
		}
		else
		{
			printf("unable to copyin arg2");
		}
	}
	else 
	{
		printf("arg2 is 0");
	}
}


fbt:nt:ObCreateObjectEx:return
{
/*	
 	print(self->arg); 
	print(*(struct nt`_OBJECT_TYPE *) self->arg);
	self->obj_type = (struct nt`_OBJECT_TYPE *) self->arg;
	print(self->obj_type->Name);
	
	printf("Object Name =  %.*ws \n", 
       		self->obj_type->Name.Length / 2, ((struct ustr*)self->obj_type->Name.Buffer)->buffer);
 	
	this->str = *((uintptr_t*)copyin((uintptr_t)self->obj_type->Name.Buffer, self->obj_type->Name.Length));
    	printf("Object Type Name = %s", copyinstr(this->str));


	self->arg9 = copyin(arg9,sizeof(nt`_OBJECT_HEADER *)); 
	tracemem(self->arg9, sizeof(nt`_OBJECT_HEADER));
*/
}

