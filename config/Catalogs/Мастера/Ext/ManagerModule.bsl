﻿Функция ПолучитьСрокиНапоминанийМастера(Мастер) Экспорт 
	
	Результат = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	МастераВремяНапоминанияОЗаписи.МинДоЗаписи КАК МинДоЗаписи
	|ИЗ
	|	Справочник.Мастера.ВремяНапоминанияОЗаписи КАК МастераВремяНапоминанияОЗаписи
	|ГДЕ
	|	МастераВремяНапоминанияОЗаписи.Ссылка = &Мастер";
	
	Запрос.УстановитьПараметр("Мастер", Мастер);
	
	Результат = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("МинДоЗаписи");
	
	Возврат Результат;
	
КонецФункции
