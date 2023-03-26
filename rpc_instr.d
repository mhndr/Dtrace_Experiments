

pid$target:RPCRT4:$1:entry
{
	printf("\nExecutable : %s\n",execname);
	printf("%s(0x%X, 0x%X, 0x%X)\t\t\n",probefunc,arg0,arg1,arg2);

	self->start_time = timestamp;  
	self->profile = 1; 
}


pid$target:RPCRT4:$1:return
{
	self->profile = 0;
	printf("\nFunction - %s",probefunc);
	printf("\nReturn Value : %d",arg1);
	printf("\nReturn Offset  : %d",(int)arg0);

 	printf("\n%d ms (real)\n",
        (timestamp - self->start_time) / 1000000);
	exit(0);
}
   


pid$target:RPCRT4:$1:
/self->profile==1/
{
}
