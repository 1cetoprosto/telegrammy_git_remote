﻿
///////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ

&НаКлиенте
Перем ПредыдущаяВыделеннаяДатаКалендаря;
&НаКлиенте
Перем ПредыдущееОтображение;

&НаКлиенте
Процедура ДатаКалендаряПриВыводеПериода(Элемент, ОформлениеПериода)
	
	мРабочиеДниМастера = ДниМастера(ОформлениеПериода.НачалоПериода, ОформлениеПериода.КонецПериода, Истина);
	мВыходныеДниМастера = ДниМастера(ОформлениеПериода.НачалоПериода, ОформлениеПериода.КонецПериода, Ложь);
	Попытка
		Для каждого ТекДата Из ОформлениеПериода.Даты Цикл
			Если НЕ мРабочиеДниМастера.Найти(ТекДата.Дата) = Неопределено Тогда
				ТекДата.ЦветФона = ЦветРабочий;
			ИначеЕсли НЕ мВыходныеДниМастера.Найти(ТекДата.Дата) = Неопределено Тогда
				ТекДата.ЦветФона = ЦветВыходной;
			Иначе
				ТекДата.ЦветФона = webЦвета.Белый;    
			КонецЕсли;     
			Если ДеньНедели(ТекДата.Дата)>=6 Тогда
				ТекДата.ЦветТекста = webЦвета.Красный; 
			КонецЕсли;
		КонецЦикла;
	Исключение
	КонецПопытки;

КонецПроцедуры

&НаКлиенте
Процедура ДатаКалендаряПриИзменении(Элемент)
	ПодключитьОбработчикОжидания("Подключаемый_ОбработчикОжиданияДатаКалендаряПриИзменении", 0.1, Истина);
КонецПроцедуры


&НаКлиенте
Процедура НастройкиМастера(Команда)
	
	П = Новый Структура;
	П.Вставить("Ключ", ТекущийМастер);
	
	ОткрытьФорму("Справочник.Мастера.ФормаОбъекта", П);
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ ОЖИДАНИЯ

&НаКлиенте
Процедура Подключаемый_ОбработчикОжиданияДатаКалендаряПриИзменении()
	//Если	Объект.ТекущееОтображение = "День"
	//	Или Объект.ТекущееОтображение = "Неделя"
	//	Или Объект.ТекущееОтображение = "ПоРесурсам"
	//	Или Объект.ТекущееОтображение = "Расписание"
	//	Или Объект.ТекущееОтображение = "Список"
	//	Или Объект.ТекущееОтображение = "Диспетчеризация" Тогда
	//	//
	//	Если Объект.ТекущееОтображение = "Список" Тогда
	//		МассивВыбранныхДат = ПолучитьМассивВыбранныхДат();
	//		КалендарьСписокПериодНачало		= НачалоДня(МассивВыбранныхДат[0]);
	//		КалендарьСписокПериодОкончание	= НачалоДня(МассивВыбранныхДат[МассивВыбранныхДат.ВГраница()]);
	//	КонецЕсли;
	//	
	//	КалендарьОбновитьКлиент();
	//КонецЕсли;
	
	ОбновитьДанныеПланировщикаСервер();
	
	ПредыдущаяВыделеннаяДатаКалендаря = ДатаКалендаря;
КонецПроцедуры

&НаСервере
Функция ЕстьЗаписиКлиентовНаДату(Мастер, МассивДат)

	Результат = Ложь;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЗаписиНаПрием.ДатаВремяЗаписи КАК ДатаВремяЗаписи
		|ИЗ
		|	РегистрСведений.ЗаписиНаПрием КАК ЗаписиНаПрием
		|ГДЕ
		|	ЗаписиНаПрием.Мастер = &Мастер
		|	И НАЧАЛОПЕРИОДА(ЗаписиНаПрием.ДатаВремяЗаписи, ДЕНЬ) В (&МассивДат)";
	
	Запрос.УстановитьПараметр("Мастер", Мастер);
	Запрос.УстановитьПараметр("МассивДат", МассивДат);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Результат = Истина;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ЗаписатьВыходныеДниНаСервере(МассивВыделенныхДат)
	
	// предварительно проверим нет ли записей клиентов за МассивВыделенныхДат
	Если ЕстьЗаписиКлиентовНаДату(ТекущийМастер, МассивВыделенныхДат) Тогда
		Сообщить("Есть записи клиентов на выбранные даты. Установка выходных невозможна." + Символы.ПС
		 + "Выбирите другие дни или перепишите клиентов на другой день.");
		Возврат;
	КонецЕсли;
	
	//удаляем все записи по Мастеру за Выделенные даты
	ЗапросОставляемыеЗаписи = Новый Запрос;
	ЗапросОставляемыеЗаписи.Текст = 
	"ВЫБРАТЬ
	|	РабочиеДниМастеров.Мастер КАК Мастер,
	|	РабочиеДниМастеров.НомерНедели КАК НомерНедели,
	|	РабочиеДниМастеров.ДатаВремяЗаписи КАК ДатаВремяЗаписи,
	|	РабочиеДниМастеров.Рабочий КАК Рабочий
	|ИЗ
	|	РегистрСведений.РабочиеДниМастеров КАК РабочиеДниМастеров
	|ГДЕ
	|	НЕ РабочиеДниМастеров.Мастер = &Мастер
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	РабочиеДниМастеров.Мастер,
	|	РабочиеДниМастеров.НомерНедели,
	|	РабочиеДниМастеров.ДатаВремяЗаписи,
	|	РабочиеДниМастеров.Рабочий
	|ИЗ
	|	РегистрСведений.РабочиеДниМастеров КАК РабочиеДниМастеров
	|ГДЕ
	|	РабочиеДниМастеров.Мастер = &Мастер
	|	И НЕ НАЧАЛОПЕРИОДА(РабочиеДниМастеров.ДатаВремяЗаписи, ДЕНЬ) В (&мДат)";
	
	ЗапросОставляемыеЗаписи.УстановитьПараметр("Мастер", ТекущийМастер);
	ЗапросОставляемыеЗаписи.УстановитьПараметр("мДат", МассивВыделенныхДат);
	
	ТаблицаОставляемыхЗаписей = ЗапросОставляемыеЗаписи.Выполнить().Выгрузить();
	НаборЗаписей = РегистрыСведений.РабочиеДниМастеров.СоздатьНаборЗаписей();
	НаборЗаписей.Загрузить(ТаблицаОставляемыхЗаписей);
	НаборЗаписей.Записать();
	
	
	НаборЗаписей.Отбор.Мастер.Установить(ТекущийМастер);
	НаборЗаписей.Прочитать();
	
	Для каждого ВыделеннаяДата Из МассивВыделенныхДат Цикл
		
		//НаборЗаписей.Отбор.ДатаВремяЗаписи.Установить(ВыделеннаяДата);
		НаборЗаписей.Прочитать();
		
		НоваяЗапись = НаборЗаписей.Добавить();
		НоваяЗапись.Мастер = ТекущийМастер; 
		НоваяЗапись.НомерНедели = НеделяГода(ВыделеннаяДата); 
		НоваяЗапись.ДатаВремяЗаписи = ВыделеннаяДата;
		НоваяЗапись.Рабочий = Ложь;
		НаборЗаписей.Записать();
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьВыходныеДни(Команда)
	МассивВыделенныхДат = Элементы.ДатаКалендаря.ВыделенныеДаты;
	ЗаписатьВыходныеДниНаСервере(МассивВыделенныхДат);
	ОбновитьНадписиНаФорме();
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьРабочиеДни(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ВводВремениЗаписиЗавершение", ЭтаФорма);
	стрПараметров = Новый Структура("ТекущийМастер", ТекущийМастер);
	ОткрытьФорму("РегистрСведений.РабочиеДниМастеров.Форма.ФормаВыбораВремени", стрПараметров, , , , , ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ВводВремениЗаписиЗавершение(Результат, Параметры) Экспорт 
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВремяЗаписи = Результат;
	МассивВыделенныхДат = Элементы.ДатаКалендаря.ВыделенныеДаты;
	ЗаписатьРабочиеДниНаСервере(МассивВыделенныхДат, ВремяЗаписи);
	ОбновитьНадписиНаФорме();
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьРабочиеДниНаСервере(МассивВыделенныхДат, ВремяЗаписи)
	
	НаборЗаписей = РегистрыСведений.РабочиеДниМастеров.СоздатьНаборЗаписей();
	
	// удалим запись о выходном дне, если она есть
	НаборЗаписей.Отбор.Мастер.Установить(ТекущийМастер);
	Для каждого ВыделеннаяДата Из МассивВыделенныхДат Цикл
		НаборЗаписей.Отбор.ДатаВремяЗаписи.Установить(НачалоДня(ВыделеннаяДата));
		НаборЗаписей.Записать();
	КонецЦикла;
	
	// запишем новый график
	НаборЗаписей.Отбор.Сбросить();
	НаборЗаписей.Отбор.Мастер.Установить(ТекущийМастер);
	
	//НаборЗаписей.Отбор.ДатаВремяЗаписи.Установить(ТекущийМастер)
	
	Для каждого ВыделеннаяДата Из МассивВыделенныхДат Цикл
		                                 
		Для каждого ВыбранноеВремя Из ВремяЗаписи Цикл
			
			НоваяЗапись = НаборЗаписей.Добавить(); 
			
			НоваяЗапись.Мастер = ТекущийМастер; 
			НоваяЗапись.НомерНедели = НеделяГода(ВыделеннаяДата);
			
			ДатаСтрока = Формат(ВыделеннаяДата, "ДФ=""ггггММдд""");
			ВремяСтрока = СтрЗаменить(ВыбранноеВремя,":","");
			ВремяСтрока = ?(СтрДлина(ВремяСтрока)<6,"0"+ВремяСтрока,ВремяСтрока);
			ВремяСтрока = Формат(ВремяСтрока, "ДФ=""ЧЧммсс""");
			Результат = Дата(ДатаСтрока + ВремяСтрока);
			НоваяЗапись.ДатаВремяЗаписи = Результат;
			
			НоваяЗапись.Рабочий = Истина;
			
		КонецЦикла;
		
	КонецЦикла;
	
	НаборЗаписей.Записать(Ложь);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	//Если Параметры.Отбор.Свойство("Мастер") Тогда
	//	ТекущийМастер = Параметры.Отбор.Мастер;
	//Иначе
	//	Если Не РольДоступна("Администратор") Тогда
			ТекущийМастер = Регистратура.ПолучитьМастераПоЛогину(ПараметрыСеанса.ТекущийПользователь);
			Если ТекущийМастер = Справочники.Мастера.ПустаяСсылка() Тогда
				Отказ = Истина;
				Возврат;
			КонецЕсли;	
	//	КонецЕсли; 
	//КонецЕсли;
	
	ЗаполнитьТаблицуКонтрагентов();
	
	ВосстановитьНастройки();
	
	ОбновитьДанныеПланировщикаСервер();
	
КонецПроцедуры

&НаСервере
Процедура НастроитьВидимостьИДоступностьФормы()
	
	Элементы.ГруппаСписок.Видимость = Ложь;
	Элементы.ФормаСправочникНоменклатураМастеровОткрытьПоЗначению.Видимость = Ложь;
	Элементы.ФормаНастройкиМастера.Видимость = Ложь;
	//Элементы.ГруппаСправа.Видимость = Ложь;
	
КонецПроцедуры
	
&НаКлиенте
// Процедура - обработчик события формы "ПриОткрытии".
//
Процедура ПриОткрытии(Отказ)
	
	НастроитьВидимостьИДоступностьФормы();
	//ПрименитьНастройкиЭлементовОтборов();
	//НастройкиОбщие = ПолучитьНастройкиОбщиеКлиент();
	
	ПредыдущаяВыделеннаяДатаКалендаря = ДатаКалендаря;
	ПредыдущееОтображение = ТекущееОтображение;
	
	Элементы.ДекорацияВыходной.ЦветФона = ЦветВыходной;
	Элементы.ДекорацияРабочий.ЦветФона = ЦветРабочий;
	Элементы.ЗаписатьВыходныеДни.ЦветФона = ЦветВыходной;
	Элементы.ЗаписатьРабочиеДни.ЦветФона = ЦветРабочий;
	
	#Если МобильныйКлиент Тогда
		Элементы.ДекорацияИнструкция.Заголовок = "1. Для установки выходных дней, выбирите их в календаре и нажмите кнопку ""Выходной""" + Символы.ПС
		+ "2. Для установки рабочих дней, выбирите их в календаре и нажмите кнопку ""Рабочий""";
		
		Если СредстваТелефонии.ПоддерживаетсяОбработкаЗвонков() Тогда
			ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьЗвонок", ЭтаФорма);
			СредстваТелефонии.ПодключитьОбработчикЗвонков(ОписаниеОповещения);
		КонецЕсли;
	#КонецЕсли  
		
	//Если СписокВыборМесяца.Количество() > 0 Тогда
	//	СписокВыборМесяцаНеОбрабатыватьПриАктивизацииСтроки = Истина;
	//	ВыделитьМесяцВСписке();
	//КонецЕсли;
	//ДеревоРесурсовЭлементы = ДеревоРесурсов.ПолучитьЭлементы();
	//Если ДеревоРесурсовЭлементы.Количество() > 0 Тогда
	//	ДеревоРесурсовНеОбрабатыватьПриАктивизацииСтроки = Истина;
	//	Элементы.ДеревоРесурсов.ТекущаяСтрока = ДеревоРесурсовЭлементы[0].ПолучитьИдентификатор();
	//КонецЕсли;
	//
	//Если Объект.ТекущееОтображение = "Неделя" Тогда
	//	ДатаКалендаряВыделитьНеделю();
	//КонецЕсли;
	//КалендарьОбновитьКлиент();
	//
	//Если Элементы.ГруппаСписокЗадач.Видимость Тогда
	//	РазвернутьСписокЗадач();
	//КонецЕсли;
	//
	//Если ИспользоватьГруппыПользователей Тогда
	//	Попытка Элементы.ГруппыПользователей.ТекущаяСтрока = ПредопределенноеЗначение("Справочник.ГруппыПользователей.ВсеПользователи");
	//	Исключение КонецПопытки;
	//КонецЕсли;
	//
	//ОбновитьСодержимоеФормыПриИзмененииГруппы();
	//
	//Попытка Элементы.СписокПользователейДиспетчеризация.ТекущаяСтрока = ТекущийПользовательСеанса;
	//Исключение КонецПопытки;
	//Попытка Элементы.ДеревоПользователейДиспетчеризации.ТекущаяСтрока = ДеревоПользователейДиспетчеризации.ПолучитьЭлементы()[0].ПолучитьЭлементы()[0].ПолучитьИдентификатор();
	//Исключение КонецПопытки;
	//
	//Если	НастройкиОбщие.Свойство("Автообновление") И НастройкиОбщие.Автообновление = Истина
	//	И	НастройкиОбщие.Свойство("ПериодАвтообновления") И ТипЗнч(НастройкиОбщие.ПериодАвтообновления) = Тип("Число") Тогда
	//	//
	//	ПодключитьОбработчикОжидания("Подключаемый_Автообновление", Макс(НастройкиОбщие.ПериодАвтообновления * 60, 60));
	//КонецЕсли;
	//
	//Если НЕ ПолучитьИспользованиеПолнотекствогоПоиска() Тогда
	//	Элементы.ДекорацияПолнотекстовыйПоискОтлючен.Видимость = Истина;
	//КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьЗвонок(НомерТелефона, Дата, ВариантСобытия=Неопределено, ТипЗвонка=Неопределено, ДополнительныйПараметр=Неопределено) Экспорт 
	
	#Если МобильныйКлиент Тогда
		Если ВариантСобытия = ВариантСобытияЗвонкаСредствТелефонии.НачалоВходящего Тогда
			Контрагент = НайтиКонтрагентаПоТелефону(НомерТелефона);	
			//Если Не Контрагент = Неопределено Тогда
			//	
			//	докЗаписьНаПрием = СоздатьЗаписьНаПриемНаСервере(Контрагент);
			//	
			//	//ФормаОбъекта = докЗаписьНаПрием.ПолучитьФорму("Документ.ЗаписьНаПрием.ФормаОбъекта");
			//	//ФормаОбъекта.Открыть();
			//	ПараметрыФормы = Новый Структура("Ключ", докЗаписьНаПрием);
			//	ОткрытьФорму("Документ.ЗаписьНаПрием.Форма.ФормаДокумента", ПараметрыФормы);
			//КонецЕсли;
		КонецЕсли;
	#КонецЕсли
	
КонецПроцедуры

&НаСервере
Функция СоздатьЗаписьНаПриемНаСервере(Контрагент)
	
	ДокЗаписьНаПрием = Неопределено;
	
	докЗаписьНаПрием = Документы.ЗаписьНаПрием.СоздатьДокумент();
	докЗаписьНаПрием.Заполнить(Контрагент);
	докЗаписьНаПрием.Записать();
	
	Возврат докЗаписьНаПрием.Ссылка;
	
КонецФункции

&НаСервере
Функция ДниМастера(НачПериода, КонПериода, Рабочий)
	
	мДниМастера = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	НАЧАЛОПЕРИОДА(РабочиеДниМастеров.ДатаВремяЗаписи, ДЕНЬ) КАК ДатаВремяЗаписи
		|ИЗ
		|	РегистрСведений.РабочиеДниМастеров КАК РабочиеДниМастеров
		|ГДЕ
		|	РабочиеДниМастеров.Рабочий = &Рабочий
		|	И РабочиеДниМастеров.Мастер = &Мастер
		|	И РабочиеДниМастеров.ДатаВремяЗаписи МЕЖДУ &НачПериода И &КонПериода
		|
		|СГРУППИРОВАТЬ ПО
		|	НАЧАЛОПЕРИОДА(РабочиеДниМастеров.ДатаВремяЗаписи, ДЕНЬ)
		|АВТОУПОРЯДОЧИВАНИЕ";
	
	Запрос.УстановитьПараметр("КонПериода", КонПериода);
	Запрос.УстановитьПараметр("Мастер", ТекущийМастер);
	Запрос.УстановитьПараметр("НачПериода", НачПериода);
	Запрос.УстановитьПараметр("Рабочий", Рабочий);
	
	мДниМастера = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ДатаВремяЗаписи");
	
	Возврат мДниМастера;
	
КонецФункции

&НаКлиенте
Процедура ОбновитьНадписиНаФорме()
	Элементы.Список.Обновить();
	Элементы.ДатаКалендаря.Обновить();
КонецПроцедуры

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция НайтиКонтрагентаПоТелефону(НомерТелефона)
	
	Контрагент = Неопределено;
	
	Если ЗначениеЗаполнено(НомерТелефона) Тогда
		НомерТелефона = СтрЗаменить(НомерТелефона,"+","");
		НомерТелефона = Прав(НомерТелефона, 10);
		Отбор = Новый Структура("Телефон", НомерТелефона);
		
		Строки = ТаблицаКонтрагентов.НайтиСтроки(Отбор);
		
		Если Строки.Количество() > 0 Тогда
			Контрагент = Строки[0].Контрагент; 
		КонецЕсли;
	КонецЕсли;
	
	Возврат Контрагент;
	
КонецФункции

&НаСервере
Процедура СохранитьНастройкиИОбновитьДанныеПланировщикаСервер()
	
	//СохранитьНастройки();
	ОбновитьДанныеПланировщикаСервер();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуКонтрагентов()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контрагенты.Ссылка КАК Контрагент,
		|	Контрагенты.Телефон КАК Телефон
		|ИЗ
		|	Справочник.Контрагенты КАК Контрагенты
		|ГДЕ
		|	Контрагенты.ПометкаУдаления = ЛОЖЬ";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		НовСтр = ТаблицаКонтрагентов.Добавить();
		ЗаполнитьЗначенияСвойств(НовСтр, ВыборкаДетальныеЗаписи);
	КонецЦикла;
	
КонецПроцедуры

//&НаСервере
//Процедура СохранитьНастройки()
//	
//	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("НастройкиКалендаряСотрудника",
//		"ВариантПериода",
//		ВариантПериода
//	);
//	
//	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("НастройкиКалендаряСотрудника",
//		"Отображение",
//		НастройкиОтображения
//	);
//	
//	СохранитьНастройкиДоступныхКалендарей();
//	
//КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьПериодДанных(ВариантПериода, ДатаОтображения)
	
	Результат = Новый Структура("ДатаНачала, ДатаОкончания");
	
	Если ВариантПериода = "День" Тогда
		Результат.ДатаНачала	= НачалоДня(ДатаОтображения);
		Результат.ДатаОкончания	= КонецДня(ДатаОтображения);
	ИначеЕсли ВариантПериода = "Неделя" Тогда
		Результат.ДатаНачала	= НачалоНедели(ДатаОтображения);
		Результат.ДатаОкончания	= КонецНедели(ДатаОтображения);
	ИначеЕсли ВариантПериода = "Месяц" Тогда
		Результат.ДатаНачала	= НачалоНедели(НачалоМесяца(ДатаОтображения));
		Результат.ДатаОкончания	= КонецНедели(КонецМесяца(ДатаОтображения));
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ВыделитьДатыОтображения(Форма)
	
	ПолеКалендаря = Форма.Элементы.ДатаКалендаря;
	
	ПолеКалендаря.ВыделенныеДаты.Очистить();
	
	Если Форма.ВариантПериода = "Месяц" Тогда
		// Для варианта "Месяц" выделенные даты календаря отличаются от фактического периода.
		// Фактический период должен быть кратен 7 дням (недели).
		// Но в поле календаря выделяются даты только в пределах месяца.
		ПериодДанных = Новый Структура("ДатаНачала, ДатаОкончания");
		ПериодДанных.ДатаНачала		= НачалоМесяца(Форма.ДатаКалендаря);
		ПериодДанных.ДатаОкончания	= КонецМесяца(Форма.ДатаКалендаря);
	Иначе
		ПериодДанных = ПолучитьПериодДанных(Форма.ВариантПериода, Форма.ДатаКалендаря);
	КонецЕсли;
	
	ТекДата = ПериодДанных.ДатаНачала;
	
	Пока ТекДата < ПериодДанных.ДатаОкончания Цикл
		ПолеКалендаря.ВыделенныеДаты.Добавить(ТекДата);
		ТекДата = ТекДата + 86400;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьДанныеПланировщикаСервер()
	
	Планировщик.Элементы.Очистить();
	Планировщик.ИнтервалыФона.Очистить();
	
	УстановитьОтображениеПланировщика();
	
	ПериодДанных = ПолучитьПериодДанных(ВариантПериода, ДатаКалендаря);
	
	Планировщик.ТекущиеПериодыОтображения.Очистить();
	Планировщик.ТекущиеПериодыОтображения.Добавить(ПериодДанных.ДатаНачала, ПериодДанных.ДатаОкончания);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаписиНаПрием.Контрагент КАК Контрагент,
	|	ЗаписиНаПрием.Номенклатура КАК Номенклатура,
	|	ЗаписиНаПрием.ТипЗаписиНаПрием КАК ТипЗаписиНаПрием,
	|	ЗаписиНаПрием.ДатаВремяЗаписи КАК Начало,
	|	ДОБАВИТЬКДАТЕ(ЗаписиНаПрием.ДатаВремяЗаписи, МИНУТА, ЗаписиНаПрием.Номенклатура.Длительность) КАК Конец,
	|	ЗаписиНаПрием.Контрагент.Телефон КАК КонтрагентТелефон
	|ИЗ
	|	РегистрСведений.ЗаписиНаПрием КАК ЗаписиНаПрием
	|ГДЕ
	|	ЗаписиНаПрием.Мастер = &Мастер
	|	И ЗаписиНаПрием.ДатаВремяЗаписи МЕЖДУ &НачПериода И &КонПериода
	|
	|УПОРЯДОЧИТЬ ПО
	|	ЗаписиНаПрием.ДатаВремяЗаписи";
	
	Запрос.УстановитьПараметр("КонПериода", КонецМесяца(ДатаКалендаря));  
	Запрос.УстановитьПараметр("Мастер", ТекущийМастер);
	Запрос.УстановитьПараметр("НачПериода", НачалоМесяца(ДатаКалендаря));
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ЭлементПланировщика = Планировщик.Элементы.Добавить(Выборка.Начало, Выборка.Конец);
		ЭлементПланировщика.Значение = Новый Структура;
		ЭлементПланировщика.Значение.Вставить("Контрагент", Выборка.Контрагент);
		ЭлементПланировщика.Значение.Вставить("Номенклатура", Выборка.Номенклатура);
		ЭлементПланировщика.Значение.Вставить("ТипЗаписиНаПрием", Выборка.ТипЗаписиНаПрием);
		ЭлементПланировщика.Текст = Строка(Выборка.Контрагент) + " (" + Выборка.КонтрагентТелефон + ")" + Символы.ПС
		+ Выборка.Номенклатура;
		//ЭлементПланировщика.Подсказка = Выборка.Номенклатура; //+ Символы.ПС + Формат(Выборка.Начало, "ДЛФ=В")
		
		//	ЭлементПланировщика.Картинка = МенеджерИсточника.КартинкаЗаписиКалендаря(Выборка.Источник);
		//	ЭлементПланировщика.ЦветТекста = МенеджерИсточника.ЦветТекстаЗаписиКалендаря(Выборка.Источник);
		//
		//	ЭлементПланировщика.ЦветФона = РаботаСЦветомКлиентСервер.ЦветПоНомеруКартинки(НайденныеСтроки[0].ВариантЦвета);
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьОтображениеПланировщика()
	
	Если ВариантПериода = "День" Тогда
		
		Планировщик.ОтображатьТекущуюДату = НастройкиОтображения.ОтображатьТекущуюДату;
		Планировщик.ЕдиницаПериодическогоВарианта = ТипЕдиницыШкалыВремени.Час;
		Планировщик.КратностьПериодическогоВарианта = 24;
		Планировщик.ОтступСНачалаПереносаШкалыВремени = НастройкиОтображения.НачалоРабочегоДня;
		Планировщик.ОтступСКонцаПереносаШкалыВремени = ?(НастройкиОтображения.ОкончаниеРабочегоДня = 0, 0, 24 - НастройкиОтображения.ОкончаниеРабочегоДня) - ТекущийМастер.ШагЗаписи/60;
		Планировщик.ОтображатьПеренесенныеЗаголовки = Истина;
		Планировщик.ОтображатьПеренесенныеЗаголовкиШкалыВремени = Ложь;
		Планировщик.ОтображениеВремениЭлементов = ОтображениеВремениЭлементовПланировщика.ВремяНачалаИКонца;
		Планировщик.ФорматПеренесенныхЗаголовковШкалыВремени = "ДФ='dddd, d MMMM yyyy'";
		Планировщик.ШкалаВремени.Положение = ПоложениеШкалыВремени.Лево;
		Планировщик.ШкалаВремени.Элементы[0].Формат = "ДФ=ЧЧ:мм";
		Планировщик.ШкалаВремени.Элементы[0].Кратность = 1;
		Планировщик.ШкалаВремени.Элементы[0].Единица = ТипЕдиницыШкалыВремени.Час;
		
	ИначеЕсли ВариантПериода = "Неделя" Тогда
		
		Планировщик.ОтображатьТекущуюДату = НастройкиОтображения.ОтображатьТекущуюДату;
		Планировщик.ЕдиницаПериодическогоВарианта = ТипЕдиницыШкалыВремени.Час;
		Планировщик.КратностьПериодическогоВарианта = 24;
		Планировщик.ОтступСНачалаПереносаШкалыВремени = НастройкиОтображения.НачалоРабочегоДня;
		Планировщик.ОтступСКонцаПереносаШкалыВремени = ?(НастройкиОтображения.ОкончаниеРабочегоДня = 0, 0, 24 - НастройкиОтображения.ОкончаниеРабочегоДня);
		Планировщик.ОтображатьПеренесенныеЗаголовки = Истина;
		Планировщик.ОтображатьПеренесенныеЗаголовкиШкалыВремени = Ложь;
		Планировщик.ОтображениеВремениЭлементов = ОтображениеВремениЭлементовПланировщика.НеОтображать;
		Планировщик.ФорматПеренесенныхЗаголовковШкалыВремени = "ДФ='ddd, d MMMM'";
		Планировщик.ШкалаВремени.Положение = ПоложениеШкалыВремени.Лево;
		Планировщик.ШкалаВремени.Элементы[0].Формат = "ДФ=ЧЧ:мм";
		Планировщик.ШкалаВремени.Элементы[0].Кратность = 1;
		Планировщик.ШкалаВремени.Элементы[0].Единица = ТипЕдиницыШкалыВремени.Час;
		
	ИначеЕсли ВариантПериода = "Месяц" Тогда
		
		Планировщик.ОтображатьТекущуюДату = Ложь;
		Планировщик.ЕдиницаПериодическогоВарианта = ТипЕдиницыШкалыВремени.День;
		Планировщик.КратностьПериодическогоВарианта = 7;
		Планировщик.ОтступСНачалаПереносаШкалыВремени = 0;
		Планировщик.ОтступСКонцаПереносаШкалыВремени = 0;
		Планировщик.ОтображатьПеренесенныеЗаголовки = Ложь;
		Планировщик.ОтображатьПеренесенныеЗаголовкиШкалыВремени = Истина;
		Планировщик.ОтображениеВремениЭлементов = ОтображениеВремениЭлементовПланировщика.НеОтображать;
		Планировщик.ФорматПеренесенныхЗаголовковШкалыВремени = "ДФ='ddd, d MMM yyyy'";
		Планировщик.ШкалаВремени.Положение = ПоложениеШкалыВремени.Верх;
		Планировщик.ШкалаВремени.Элементы[0].Формат = "ДФ='ddd, d MMM yyyy'";
		Планировщик.ШкалаВремени.Элементы[0].Кратность = 1;
		Планировщик.ШкалаВремени.Элементы[0].Единица = ТипЕдиницыШкалыВремени.День;
		
		Интервал = Планировщик.ИнтервалыФона.Добавить(НачалоМесяца(ДатаКалендаря), КонецМесяца(ДатаКалендаря));
		Интервал.Цвет = Новый Цвет(250, 250, 250);
		Если НастройкиОтображения.ОтображатьТекущуюДату Тогда
			ТекущаяДатаСеанса = ТекущаяДатаСеанса();
			Интервал = Планировщик.ИнтервалыФона.Добавить(НачалоДня(ТекущаяДатаСеанса), КонецДня(ТекущаяДатаСеанса));
			Интервал.Цвет = Новый Цвет(223, 255, 223);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ВосстановитьНастройки()
	
	//ВариантПериода = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("НастройкиКалендаряСотрудника",
	//	"ВариантПериода",
	//	Элементы.ВариантПериода.СписокВыбора[0].Значение
	//);
	//
	//НастройкиОтображения = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("НастройкиКалендаряСотрудника",
	//	"Отображение",
	//	Неопределено
	//);
	//
	//Если НастройкиОтображения = Неопределено Тогда
	
	НачалоРабочегоДняЧислом = 9;
	ОкончаниеРабочегоДняЧислом = 18;
	ВремяПриемовМастера = ТекущийМастер.ВремяПриемов;
	Если ВремяПриемовМастера.Количество() > 0 Тогда
		НачалоРабочегоДняЧислом = (ВремяПриемовМастера[0].ВремяПриема - Дата("00010101000000"))/60/60;
		ОкончаниеРабочегоДняЧислом = (ВремяПриемовМастера[ВремяПриемовМастера.Количество()-1].ВремяПриема- Дата("00010101000000"))/60/60;
	КонецЕсли;
	НастройкиОтображения = Новый Структура;
	НастройкиОтображения.Вставить("НачалоРабочегоДня",		НачалоРабочегоДняЧислом);
	НастройкиОтображения.Вставить("ОкончаниеРабочегоДня",	ОкончаниеРабочегоДняЧислом);
	НастройкиОтображения.Вставить("ОтображатьТекущуюДату",	Истина);
	
	//КонецЕсли;
	
	ЦветВыходной = webЦвета.Персиковый;
	ЦветРабочий = webЦвета.БледноЗеленый;
	ДатаКалендаря = ТекущаяДатаСеанса();
	ВариантПериода = "День"; //Неделя
	
	Планировщик.ШкалаВремени.Элементы[0].ФорматДня = ФорматДняШкалыВремени.ДеньМесяцаДеньНедели;
	Если ТекущийМастер.ШагЗаписи > 100 Тогда
		Планировщик.ШкалаВремени.Элементы[0].Единица = ТипЕдиницыШкалыВремени.Час;
		Планировщик.ШкалаВремени.Элементы[0].Кратность = Окр(ТекущийМастер.ШагЗаписи/60, 0);
	Иначе 
		Планировщик.ШкалаВремени.Элементы[0].Единица = ТипЕдиницыШкалыВремени.Минута;
		Планировщик.ШкалаВремени.Элементы[0].Кратность = ТекущийМастер.ШагЗаписи;
	КонецЕсли;
	
	ВыделитьДатыОтображения(ЭтотОбъект);
	УстановитьПредставлениеПериода(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ВариантПериодаПриИзменении(Элемент)
	
	ВыделитьДатыОтображения(ЭтотОбъект);
	УстановитьПредставлениеПериода(ЭтотОбъект);
	Элементы.ДатаКалендаря.Обновить();
	
	СохранитьНастройкиИОбновитьДанныеПланировщикаСервер();
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьПредставлениеПериода(Форма)
	
	КодЯзыка = Локализация.КодЯзыкаИнтерфейса();
	
	Если Форма.ВариантПериода = "День" Тогда
		
		Форма.ПредставлениеПериода = Формат(Форма.ДатаКалендаря, "Л="+Локализация.ОпределитьКодЯзыкаДляФормат(КодЯзыка)+"; ДФ='дддд, д МММ'");
		
	ИначеЕсли Форма.ВариантПериода = "Неделя" Тогда
		
		ПериодДанных = ПолучитьПериодДанных(Форма.ВариантПериода, Форма.ДатаКалендаря);
		Форма.ПредставлениеПериода = СтрШаблон(
			"%1 - %2",
			Формат(ПериодДанных.ДатаНачала, "Л="+Локализация.ОпределитьКодЯзыкаДляФормат(КодЯзыка)+";ДФ='д МММ'"),
			Формат(ПериодДанных.ДатаОкончания, "Л="+Локализация.ОпределитьКодЯзыкаДляФормат(КодЯзыка)+";ДФ='д МММ гггг'")
		);
		
	ИначеЕсли Форма.ВариантПериода = "Месяц" Тогда
		
		Форма.ПредставлениеПериода = ПредставлениеПериода(НачалоМесяца(Форма.ДатаКалендаря), КонецМесяца(Форма.ДатаКалендаря));
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВходящийЗвонок(Команда)
	
	//#Если МобильныйКлиент Тогда
		//ВариантСобытия = ВариантСобытияЗвонкаСредствТелефонии.НачалоСигналаВходящего;
		//ТипЗвонка = ТипЗвонкаСредствТелефонии.Входящий;
		ОбработатьЗвонок("0979518043", "20190511"); //, ВариантСобытия, ТипЗвонка, ЭтаФорма);    	
	//#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьЗапись(Команда)
	
	докЗаписьНаПрием = СоздатьЗаписьНаПриемНаСервере(Контрагент);
	
	ПараметрыФормы = Новый Структура("Ключ", докЗаписьНаПрием);
	ОткрытьФорму("Документ.ЗаписьНаПрием.Форма.ФормаМастерЗаполнения", ПараметрыФормы);
	
	
КонецПроцедуры

#КонецОбласти