#!/usr/sbin/dtrace  -s
#pragma D option flowindent

syscall::$2:entry
/execname==$$1/
{
	self->traceme = 1;
}

fbt:$3::entry
/self->traceme/
{}

fbt:$3::return 
/self->traceme/
{}

syscall::$2:return
/self->traceme/
{
	self->traceme = 0;
}
