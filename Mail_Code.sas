data a;
set gcm.cust_field_value_l;
where business_object_nm="CUST_OBJ_86";
run;

proc sort data=a;
by   business_object_rk;
run;

 

proc transpose data=a out=work.custf_l(keep=business_object_rk x_86_grossloss);
by business_object_rk;
id cust_field_nm;
var value_no;
run;

proc sql;
Create table gcm.cust_86_incident as
select * from gcm.cust_obj_86 a  left join work.custf_l b
on a.cust_obj_86_rk =b.business_object_rk;
run;

proc sql;
create table work.final as
select * from gcm.cust_86_incident
where(cust_86_incident.x_86_grossloss>5000000);
run;


options emailsys=smtp emailhost= "smtp.it.nednet.co.za" emailport=25 
EMAILID=noreply@nedbank.co.za  ;
filename outmail email type='text/html';

data _null_;
set work.final;
file outmail;
put '!EM_TO!' Materialoperationalriskevents@Nedbank.co.za ;
put '!EM_SUBJECT! SAS Alert: Gross Loss above 5 Million rands';
put '<br> Id 'cust_obj_86_rk' is above the 5 Million rands.';
put '<br>';
put '<hr>';
put 'this is system generated mail,Do not reply to this e-mail.</br>';
put '!EM_SEND!';
put '!EM_NEWMSG!';
IF eof Then put '!EM_ABORT!';
run;