﻿
Функция ОпределитьЭтаИнформационнаяБазаФайловая(СтрокаСоединенияСБД = "") Экспорт
	
	#Если НЕ МобильноеПриложениеКлиент И НЕ МобильноеПриложениеСервер Тогда
		СтрокаСоединенияСБД = ?(ПустаяСтрока(СтрокаСоединенияСБД), СтрокаСоединенияИнформационнойБазы(), СтрокаСоединенияСБД);
		
		// в зависимости от того файловый это вариант БД или нет немного по-разному путь в БД формируется
		ПозицияПоиска = Найти(Врег(СтрокаСоединенияСБД), "FILE=");
		
		Возврат ПозицияПоиска = 1;	     	
	#КонецЕсли
	
КонецФункции


