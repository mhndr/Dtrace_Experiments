#pragma D option quiet


BEGIN
{
	printf("\nDTrace Waiting...");
}

pid$target:RPCRT4:$1:entry
{
	@a[ustack()]=count()
}


tick-1s
{
	printa(@a);
	trunc(@a);
}

