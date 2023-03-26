
fbt:nt:Po*:entry
{ 
	/* self is thread local */
	self->ts = timestamp;
	@funcCount[probefunc] = count();
} 

fbt:nt:Po*:return
/self->ts/
{
	this->ts = timestamp - self->ts;
	@disttime = lquantize(this->ts,0,999999,100); 
	@funcName[probefunc] = avg(this->ts);	
	self->ts = 0;
}

tick-1s
{
	/*truncate tables periodically so that we don't run out of memory*/
	trunc(@disttime, 100);
	trunc(@funcName, 100);
	trunc(@funcCount,100);
}


END
{
	/*system ("cls");*/
	/* Print overall time distribution for top 100 Po* funtions */
	printf("function runtime distribution");
	printa (@disttime);
	
	/* Print top 100 Po* functions along with average time spent executing them */
	printf("Average time spent in top 100 functions");
	printa( @funcName);
	
	/** Print top 100 Po* functions by count*/
	printf("list of top 100 functions run");
	printa(@funcCount);
}

