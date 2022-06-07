global class Dreampass_ScheduleExpUpdate Implements Schedulable 
{
    /* 
    System.schedule('Evaluate Expirations 01',  '0 00 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 02',  '0 02 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 03',  '0 04 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 04',  '0 06 * * * ?', new Dreampass_ScheduleExpUpdate());
    System.schedule('Evaluate Expirations 05',  '0 08 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 06',  '0 10 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 07',  '0 12 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 08',  '0 14 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 09',  '0 16 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 10',  '0 18 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 11',  '0 20 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 12',  '0 22 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 13',  '0 24 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 14',  '0 26 * * * ?', new Dreampass_ScheduleExpUpdate());
    System.schedule('Evaluate Expirations 15',  '0 28 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 16',  '0 30 * * * ?', new Dreampass_ScheduleExpUpdate());
    
	System.schedule('Evaluate Expirations 17',  '0 32 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 18',  '0 34 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 19',  '0 36 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 20',  '0 38 * * * ?', new Dreampass_ScheduleExpUpdate());
    System.schedule('Evaluate Expirations 21',  '0 40 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 22',  '0 42 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 23',  '0 44 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 24',  '0 46 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 25',  '0 48 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 26',  '0 50 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 27',  '0 52 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 28',  '0 54 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 29',  '0 56 * * * ?', new Dreampass_ScheduleExpUpdate());
	System.schedule('Evaluate Expirations 30',  '0 58 * * * ?', new Dreampass_ScheduleExpUpdate());


*/




    global void execute(SchedulableContext sc)
    {
        Dreampass_Helper.updateDreampassExpirations(false);
    }
}