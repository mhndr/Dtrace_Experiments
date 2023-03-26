profile:::
{
	@a[caller] = count();
}

END
{
	printa("%@8u %a\n", @a);
}
