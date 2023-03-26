
/*ERROR{exit(0);}*/
struct ustr{uint16_t buffer[256];};
syscall::NtOpenFile:entry
{
	/*
	self->attr = (nt`POBJECT_ATTRIBUTES) copyin(arg2, sizeof(nt`POBJECT_ATTRIBUTES));
	if(self->attr) {
		print(*(struct nt`_OBJECT_ATTRIBUTES * ) self->attr);
		printf("%p",self->attr->ObjectName);
		self->objectName = (nt`PUNICODE_STRING)
			copyin((uintptr_t)self->attr->ObjectName,
			   sizeof(nt`PUNICODE_STRING));

		name = alloca(self->objectName->Length + 2);
		bcopy(self->objectName->Buffer, name, self->objectName->Length);
		printf("\nFile Name: %ws \n", ((struct ustr *)name)->buffer); 
		
	}
	*/
	if(args[2]) {
		/*print(args[2]);*/
		self->attr = (nt`POBJECT_ATTRIBUTES) copyin(arg2, sizeof(nt`POBJECT_ATTRIBUTES));
		if(self->attr) {
			/*print(*(struct nt`_OBJECT_ATTRIBUTES * ) self->attr); */
			self->objectName = (nt`PUNICODE_STRING)
				copyin((uintptr_t)self->attr->ObjectName,
				   sizeof(nt`PUNICODE_STRING));
			/*print(*(struct nt`_UNICODE_STRING *) self->objectName); */
			if (self->objectName->Length > 0 ) 
			{
				name = alloca(self->objectName->Length + 2);
				bcopy(self->objectName->Buffer, name, self->objectName->Length);
				printf("\nFile Name: %ws \n", ((struct ustr *)name)->buffer); 
			}		
		}
	}

}

/*
syscall::NtOpenFile:return
{
	if (self->attr->ObjectName) {
		printf("%p",self->attr->ObjectName);
		self->objectName = (nt`PUNICODE_STRING)
			copyin((uintptr_t)self->attr->ObjectName,
			   sizeof(nt`PUNICODE_STRING));

		name = alloca(self->objectName->Length + 2);

		bcopy(self->objectName->Buffer, name, self->objectName->Length);
		printf("File Name: %ws \n", ((struct ustr *)name)->buffer); 
		
	} 
}
*/
