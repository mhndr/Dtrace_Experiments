#pragma D option flowindent


BEGIN
{
	
	self->profile = 0
}

fbt:nt:$1:entry
/pid==$target/
{
	printf("\nExecutable : %s\n",execname);
	printf("%s(0x%X, 0x%X, 0x%X,0x%X, 0x%X, 0x%X,0x%X, 0x%X, 0x%X)))\t\t\n",probefunc,arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8);

	self->start_time = timestamp;  
	self->profile = 1; 
}


fbt:nt:$1:return
/pid==$target/
{
	self->profile = 0;
}
   

fbt:nt:Alpc*:entry
/self->profile==1/
{
}

fbt:nt:Alpc*:return
/self->profile==1/
{
}
