#pragma D option quiet


BEGIN
{
	printf("\nDTrace Waiting...");
}

pid$target:RPCRT4:$1:entry
{
	printf("\nExecutable : %s",execname);
	printf("%s(0x%X, 0x%X, 0x%X)\t\t\n",probefunc,arg0,arg1,arg2);
	self->start_time = timestamp;  
}


pid$target:RPCRT4:$1:return
{
	printf("\nFunction - %s",probefunc);
	printf("\nReturn Value : %d",arg1);
	/*printf("\nReturn Offset  : %d",(int)arg0);*/

 	printf("\n%d ms (real)\n",
        (timestamp - self->start_time) / 1000000);
	
}
   

