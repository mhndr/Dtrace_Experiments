



fbt:nt:*Create*Process*:entry
/execname==\"cmd.exe\"/
{
	print(arg0);
	@[probefunc]=count();
}
	
