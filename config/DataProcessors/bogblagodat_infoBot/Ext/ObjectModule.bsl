﻿///////////////////////////////////////////////////////////////////////////////
// <Телеграм-Бот информирования ц.Божья благодать (г.Каменец-Подольский)>
// 
////////////////////////////////////////////////////////////////////////////////

Перем Телеграм Экспорт;
Перем Бот Экспорт;


////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД БОТА
//

Функция ПолучитьСправку(Сообщение)

	ТекстСообщения = ПолучитьМакет("Справка").ПолучитьТекст();
	
	Результат = Телеграм.sendMessage(Сообщение.Чат, ТекстСообщения);
	
	Возврат Результат;

КонецФункции

Функция ОставитьОтзыв(Сообщение) Экспорт
	
	ТекстСообщения = "Оставьте отзыв о боте следующим сообщением и он будет направлен разработчику.";
	
	Результат = Телеграм.sendMessage(Сообщение.Чат, ТекстСообщения);
	
	Если Результат.ok Тогда
		ОтправленноеСообщение = Результат.result;	// Возвращаем ссылку на отправленное сообщение
	Иначе
		ТекстОписания = СтрШаблон("%1
		|Чат: %2
		|Текст: %3", Результат.description, Сообщение.Чат, ТекстСообщения);
		ЗаписьЖурналаРегистрации("ИнфоБот", УровеньЖурналаРегистрации.Ошибка,,, ТекстОписания);
	КонецЕсли;
	
	ЗаписьСессии = РегистрыСведений.СессииКонтрагентов.СоздатьМенеджерЗаписи();
	ЗаписьСессии.Бот = Телеграм.Бот;
	ЗаписьСессии.Идентификатор = Сообщение.Контрагент;
	ЗаписьСессии.ДатаСоздания = ТекущаяДата();
	ЗаписьСессии.ДанныеСессии = ЗначениеВСтрокуВнутр(Новый Структура("Действие, Сообщение", "Отзыв", ОтправленноеСообщение.message_id));
	ЗаписьСессии.Записать();
	
	Возврат Результат;
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////
// КОМАНДЫ УПРАВЛЕНИЯ СООБЩЕНИЯМИ TELEGRAM
//

//-1001227968714

////////////////////////////////////////////////////////////////////////////////
//
// Процедура ПостБожьяБлагодатьУтром
//
// Описание:
//
//
// Параметры (название, тип, дифференцированное значение)
//
Функция ПостБожьяБлагодатьВКанал() Экспорт 
	
	ВидыСообщений = Новый Массив;
	ВидыСообщений.Добавить(Перечисления.ВидыРегулярныхСообщений.Репост);
	ПараметрыСообщения = ПолучитьРегулярныеСообщения(ТекущаяДата(), ВидыСообщений);
	
	Результат = Телеграм.sendMessage("@bogblagodat", 
	ПараметрыСообщения.text,
	ПараметрыСообщения.ВидФорматирования,
	ПараметрыСообщения.ОтключитьПредварительныйПросмотрСсылок,
	ПараметрыСообщения.ТихаяОтправка);
	
	Возврат Результат;
	
КонецФункции //Запостить

Функция ПостБожьяБлагодатьВГруппу() Экспорт 
	
	ВидыСообщений = Новый Массив;
	ВидыСообщений.Добавить(Перечисления.ВидыРегулярныхСообщений.Репост);
	ПараметрыСообщения = ПолучитьРегулярныеСообщения(ТекущаяДата(), ВидыСообщений);
	
	Результат = Телеграм.sendMessage("-1001227968714", 
	ПараметрыСообщения.text,
	ПараметрыСообщения.ВидФорматирования,
	ПараметрыСообщения.ОтключитьПредварительныйПросмотрСсылок,
	ПараметрыСообщения.ТихаяОтправка);
	
	Возврат Результат;
	
КонецФункции //Запостить

////////////////////////////////////////////////////////////////////////////////
//
// Процедура Объявления
//
// Описание:
//
//
// Параметры (название, тип, дифференцированное значение)
//
Функция Объявления(Сообщение=Неопределено) Экспорт 
	
	ВидыСообщений = Новый Массив;
	ВидыСообщений.Добавить(Перечисления.ВидыРегулярныхСообщений.Объявления);
	ПараметрыСообщения = ПолучитьРегулярныеСообщения(НачалоНедели(ТекущаяДата())-1, ВидыСообщений);
	
	Результат = Телеграм.sendMessage(?(Сообщение=Неопределено,"-1001227968714",Сообщение.Чат), 
	ПараметрыСообщения.text,
	ПараметрыСообщения.ВидФорматирования,
	ПараметрыСообщения.ОтключитьПредварительныйПросмотрСсылок,
	ПараметрыСообщения.ТихаяОтправка);
	
	Возврат Результат;
	
КонецФункции //Объявления

Процедура ПрочитатьИОбработатьСообщение(Сообщение) Экспорт

	Если Сообщение.ТипОтвета = Перечисления.ТипыОтветовТелеграм.Кнопка  Тогда	
		
		ДанныеСообщения = Боты.ПолучитьДанныеСообщения(Телеграм.Бот, Сообщение.update_id);
		
		Если ДанныеСообщения.callback_query.data = "ОБЪЯВЛЕНИЯ" Тогда
			
			Результат = Объявления(Сообщение);
			
		ИначеЕсли ДанныеСообщения.callback_query.data = "ПОДКРЕПИСЬ" Тогда
			
			ТекстСообщения = "Виберіть:";
			
			Результат = Телеграм.sendMessage(Сообщение.Чат, ТекстСообщения,,,,,ПолучитьКнопкиПодкрепись());
			
		ИначеЕсли ДанныеСообщения.callback_query.data = "ОНАС" Тогда
			
			ТекстСообщения = "Виберіть:";
			
			Результат = Телеграм.sendMessage(Сообщение.Чат, ТекстСообщения,,,,,ПолучитьКнопкиОНас());
			
		ИначеЕсли ДанныеСообщения.callback_query.data = "МЫНАКАРТЕ" Тогда
			
			Результат = Телеграм.sendLocation(Сообщение.Чат, 48.6777, 26.6113); // .sendMessage(Сообщение.Чат, ТекстСообщения,,,,,ПолучитьКнопкиОНас());
			
		//ИначеЕсли ДанныеСообщения.callback_query.data = "ШКОЛАХРИСТА" Тогда
		//ИначеЕсли ДанныеСообщения.callback_query.data = "ПРОПОВЕДИ" Тогда 
			
		КонецЕсли;
		//// Найдём админов бота
		//Запрос = Новый Запрос;
		//Запрос.Текст =
		//"//здесь был текст запроса";
		//Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДата());
		//Результат = Запрос.Выполнить();
		//Если Результат.Пустой() Тогда
		//	Возврат;
		//КонецЕсли;

		//// Каждому админу отправим запрос на рассмотрение
		//Выборка = Результат.Выбрать();
		//Пока Выборка.Следующий() Цикл
		//	ИдентификаторАкцепта = Боты.СоздатьСессию(Бот, Новый Структура("Действие, Контрагент", "Акцепт", Сообщение.Контрагент));
		//	ИдентификаторЗапрета = Боты.СоздатьСессию(Бот, Новый Структура("Действие, Контрагент", "Запрет", Сообщение.Контрагент));

		//	reply_markup = СтрШаблон("{""inline_keyboard"":[[{""text"":""Разрешить"",""callback_data"":""%1""},{""text"":""Отклонить"",""callback_data"":""%2""}]]}", ИдентификаторАкцепта, ИдентификаторЗапрета);
		//	parse_mode = "Markdown";
		//	Телеграм.sendMessage(Выборка.Контрагент.ТелеграмID, СтрШаблон("Поступил запрос на предоставление доступа от [%1](http://t.me/%2).", Сообщение.Контрагент.ТелеграмИмя, Сообщение.Контрагент.ТелеграмНик), parse_mode,,,, reply_markup);
		//КонецЦикла;

		////ИзменитьКлавиатуруСообщения(Сообщение.Чат, ДанныеСообщения.callback_query.message.message_id);	// Удалим кнопку запроса.

	ИначеЕсли Сообщение.ТипОтвета = Перечисления.ТипыОтветовТелеграм.Текст Тогда	
		
		ДанныеСообщения = Боты.ПолучитьДанныеСообщения(Телеграм.Бот, Сообщение.update_id);
		
		Если СокрЛП(ДанныеСообщения.message.text) = "/start"  Тогда
			
			ТекстСообщения = "Ви хотіли б, щоб ваше повсякденне життя покращилося?"
			+" Слово Боже - ваш путівник до того, щоб зробити життя яскравішим. Читайте щоденно Біблію разом з нами!"
			+Символы.ПС
			+"@PlanBible2017Bot";
			
			Результат = Телеграм.sendMessage(Сообщение.Чат, ТекстСообщения,,,,,ПолучитьКнопкиГлавногоМеню());
			
		Иначе 
			
			ТекстСообщения = "Невідома команда!";
			
			Результат = Телеграм.sendMessage(Сообщение.Чат, ТекстСообщения);
			
		КонецЕсли;
		
	КонецЕсли;

	Если НЕ Результат = Неопределено Тогда
		Если Результат["ok"] Тогда
			Боты.ЗакрытьСообщение(Телеграм.Бот, Сообщение.update_id);
		Иначе 
			ТекстОписания = СтрШаблон("%1
			|Чат: %2
			|Текст: %3", Результат.Получить("description"), Сообщение.Чат, ТекстСообщения);
			ЗаписьЖурналаРегистрации("ИнфоБот", УровеньЖурналаРегистрации.Ошибка,,, ТекстОписания);
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
//


Функция ПолучитьКнопкиГлавногоМеню()
	
	МассивСтрок = Новый Массив;
	
	КнопкаСАЙТ = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.globe_with_meridians + " САЙТ", "http://bogblagodat.pp.ua");
	КнопкаБЛОГ = Телеграм.InlineKeyboardButton("БЛОГ", "http://bogblagodat.pp.ua/blog");
	КнопкаПОДКРЕПИСЬ = Телеграм.InlineKeyboardButton("\uD83D\uDCD6"+" ПІДКРІПИСЯ!",,"ПОДКРЕПИСЬ");
	КнопкаФОТО = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.camera + " ФОТО", "http://bogblagodat.pp.ua/foto-menu");
	КнопкаНАШАКОМАНДА = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.couple + " КОМАНДА", "http://bogblagodat.pp.ua/nasha-komanda-menu");
	КнопкаОНАС = Телеграм.InlineKeyboardButton("ПРО НАС", ,"ОНАС");

	СтрокаКнопок1 = Телеграм.InlineKeyboardMarkup_add(КнопкаСАЙТ, КнопкаБЛОГ, КнопкаПОДКРЕПИСЬ); 
	Телеграм.InlineKeyboardMarkup_row(МассивСтрок,СтрокаКнопок1);
	
	СтрокаКнопок2 = Телеграм.InlineKeyboardMarkup_add(КнопкаФОТО, КнопкаНАШАКОМАНДА,КнопкаОНАС);
	Телеграм.InlineKeyboardMarkup_row(МассивСтрок,СтрокаКнопок2);
	
	InlineKeyboard = Телеграм.InlineKeyboardMarkup(МассивСтрок);
	
	Возврат InlineKeyboard;
	
КонецФункции

Функция ПолучитьКнопкиПодкрепись()
	
	МассивСтрок = Новый Массив;
	
	КнопкаОТВЕТЫ = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.interrobang + " ВІДПОВІДІ","http://bogblagodat.pp.ua/o-nas/verouchenie");
	КнопкаПРОПОВЕДИ = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.heavylatincross + " ПРОПОВІДІ","http://bogblagodat.pp.ua/category/propovedi");
	КнопкаШКОЛАХРИСТА = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.headphones + " ШКОЛА ХРИСТА (МР3)","http://bogblagodat.pp.ua/uroki-shkoly-hrista-audio");

	СтрокаКнопок1 = Телеграм.InlineKeyboardMarkup_add(КнопкаОТВЕТЫ);
	Телеграм.InlineKeyboardMarkup_row(МассивСтрок,СтрокаКнопок1);
	
	СтрокаКнопок2 = Телеграм.InlineKeyboardMarkup_add(КнопкаПРОПОВЕДИ);
	Телеграм.InlineKeyboardMarkup_row(МассивСтрок,СтрокаКнопок2);
	
	СтрокаКнопок3 = Телеграм.InlineKeyboardMarkup_add(КнопкаШКОЛАХРИСТА);
	Телеграм.InlineKeyboardMarkup_row(МассивСтрок,СтрокаКнопок3);
	
	InlineKeyboard = Телеграм.InlineKeyboardMarkup(МассивСтрок);
	
	Возврат InlineKeyboard;
	
КонецФункции

Функция ПолучитьКнопкиОНас()
	
	МассивСтрок = Новый Массив;
	
	КнопкаИСТОРИЯ = Телеграм.InlineKeyboardButton("ІСТОРІЯ НАШОЇ ЦЕРКВИ","http://bogblagodat.pp.ua/o-nas/istoriya-nashej-tserkvi");
	КнопкаСЛУЖЕНИЯ = Телеграм.InlineKeyboardButton("СЛУЖІННЯ","http://bogblagodat.pp.ua/o-nas/nasha-tserkov");
	КнопкаОБЯВЛЕНИЯ = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.info + " ОГОЛОШЕННЯ",,"ОБЪЯВЛЕНИЯ");
	КнопкаМЫНАКАРТЕ = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.worldmap + " МИ НА КАРТІ","http://bogblagodat.pp.ua/o-nas/kak-nas-najti");
   // КнопкаМЫНАКАРТЕ = Телеграм.InlineKeyboardButton(Телеграм.Эмоджи.worldmap + " МИ НА КАРТІ",, "МЫНАКАРТЕ");
	
	СтрокаКнопок1 = Телеграм.InlineKeyboardMarkup_add(КнопкаИСТОРИЯ);
	Телеграм.InlineKeyboardMarkup_row(МассивСтрок,СтрокаКнопок1);
	
	СтрокаКнопок2 = Телеграм.InlineKeyboardMarkup_add(КнопкаСЛУЖЕНИЯ, КнопкаОБЯВЛЕНИЯ);
	Телеграм.InlineKeyboardMarkup_row(МассивСтрок,СтрокаКнопок2);
	
	СтрокаКнопок3 = Телеграм.InlineKeyboardMarkup_add(КнопкаМЫНАКАРТЕ);
	Телеграм.InlineKeyboardMarkup_row(МассивСтрок,СтрокаКнопок3);
	
	InlineKeyboard = Телеграм.InlineKeyboardMarkup(МассивСтрок);
	
	Возврат InlineKeyboard;
	
КонецФункции

// Функция ПолучитьРегулярныеСообщения
//
// Описание:
//
//
// Параметры (название, тип, дифференцированное значение)
//
// Возвращаемое значение: 
//
Функция ПолучитьРегулярныеСообщения(НаДату, ВидыСообщений)
	
Результат = Новый Структура("text,ВидФорматирования,ОтключитьПредварительныйПросмотрСсылок,ТихаяОтправка");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	РегулярныеСообщения.Текст КАК text,
		|	РегулярныеСообщения.ВидФорматирования КАК ВидФорматирования,
		|	РегулярныеСообщения.ОтключитьПредварительныйПросмотрСсылок КАК ОтключитьПредварительныйПросмотрСсылок,
		|	РегулярныеСообщения.ТихаяОтправка КАК ТихаяОтправка
		|ИЗ
		|	Справочник.РегулярныеСообщения КАК РегулярныеСообщения
		|ГДЕ
		|	РегулярныеСообщения.Дата = &НаДату
		|	И РегулярныеСообщения.Вид В(&ВидыСообщений)
		|	И РегулярныеСообщения.ПометкаУдаления = Ложь";
	
	Запрос.УстановитьПараметр("НаДату", НачалоДня(НаДату)); //НачалоДня(НачалоНедели(НаДату)-1)
	Запрос.УстановитьПараметр("ВидыСообщений", ВидыСообщений);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Результат.Вставить("text", 										Выборка.text);
		Результат.Вставить("ВидФорматирования", 						Выборка.ВидФорматирования);
		Результат.Вставить("ОтключитьПредварительныйПросмотрСсылок", 	Выборка.ОтключитьПредварительныйПросмотрСсылок);
		Результат.Вставить("ТихаяОтправка", 							Выборка.ТихаяОтправка);
	КонецЦикла;
	
	Если НЕ ЗначениеЗаполнено(Результат.text) Тогда
		Результат.text = "Немає повідомлень із типом: " + ВидыСообщений;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции //ПолучитьРегулярныеСообщения

