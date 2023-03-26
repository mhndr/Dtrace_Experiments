
fbt:nt:NtAlpcSendWaitReceivePort:return
/pid==$target/
{
	if ((0 != arg2) && (0 != arg3)) { 
		this->send_msg = (struct nt`_PORT_MESSAGE*) copyin(arg2 , sizeof(struct nt`_PORT_MESSAGE)); 
		print(*(struct nt`_PORT_MESSAGE*)this->send_msg);
		printf("\n___________________\n");
		print(execname);
		printf("\nData length = %u",this->send_msg->u1.s1.DataLength); 
		printf("\nTotal Length= %u",this->send_msg->u1.s1.TotalLength);
		printf("\nMessage Id  = %d",this->send_msg->MessageId); 
		printf("\n___________________\n");
	}
}	
