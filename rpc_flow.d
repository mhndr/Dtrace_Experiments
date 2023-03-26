#pragma D option flowindent


BEGIN
{
	
	self->profile = 0
}


pid$target:RPCRT4:$1:entry
{

	self->profile = 1; 
}


pid$target:RPCRT4:$1:return
{
	self->profile = 0;
	
}
   


pid$target:RPCRT4::entry
/self->profile==1/
{
}

pid$target:RPCRT4::return
/self->profile==1/
{
}
