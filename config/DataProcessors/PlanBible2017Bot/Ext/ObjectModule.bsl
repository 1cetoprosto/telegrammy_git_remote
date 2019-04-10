﻿///////////////////////////////////////////////////////////////////////////////
// <Телеграм-Бот План чтения Библии на год (старт 2017).>
// 
////////////////////////////////////////////////////////////////////////////////

Перем Телеграм Экспорт;
Перем ЗапросБоту Экспорт;

////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД БОТА
//

Функция ПолучитьСправку(ЗапросБоту)
	
	ТекстСообщения = ПолучитьМакет("Справка").ПолучитьТекст();
	
	Результат = Телеграм.sendMessage(ЗапросБоту.Чат, ТекстСообщения);
	
	Возврат Результат;
	
КонецФункции

Функция ОставитьОтзыв(ЗапросБоту) Экспорт
	
	ТекстСообщения = "Оставьте отзыв о боте следующим сообщением и он будет направлен разработчику.";
	
	Результат = Телеграм.sendMessage(ЗапросБоту.Чат, ТекстСообщения);
	
	Если Результат.Результат Тогда
		ОтправленноеСообщение = Результат.result;	// Возвращаем ссылку на отправленное сообщение
	Иначе
		//ТекстОписания = СтрШаблон("%1
		//|Чат: %2
		//|Текст: %3", Результат.description, ЗапросБоту.Чат, ТекстСообщения);
		ТекстОписания = СтроковыеФункцииКлиентСервер.ВставитьПараметрыВСтроку("[description]
		|Чат: [Чат]
		|Текст: [ТекстСообщения]", Новый Структура("description, Чат, ТекстСообщения",Результат["description"], ЗапросБоту.Чат, ТекстСообщения));
		ЗаписьЖурналаРегистрации("ИнфоБот", УровеньЖурналаРегистрации.Ошибка,,, ТекстОписания);
	КонецЕсли;
	
	ЗаписьСессии = РегистрыСведений.СессииКонтрагентов.СоздатьМенеджерЗаписи();
	ЗаписьСессии.Бот = Телеграм.Бот;
	ЗаписьСессии.Идентификатор = ЗапросБоту.Чат;
	ЗаписьСессии.ДатаСоздания = ТекущаяДата();
	ЗаписьСессии.ДанныеСессии = ЗначениеВСтрокуВнутр(Новый Структура("Действие, Сообщение", "Отзыв", ОтправленноеСообщение.message_id));
	ЗаписьСессии.Записать();
	
	Возврат Результат;
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////
// КОМАНДЫ УПРАВЛЕНИЯ СООБЩЕНИЯМИ TELEGRAM
//


Процедура ПостПланЧтения() Экспорт
	
	ТекстПлана = ПолучитьТекстПлана(ТекущаяДата());
	
	Если ЗначениеЗаполнено(ТекстПлана) Тогда
		ТекстСообщения = Формат(ТекущаяДата(), "ДЛФ=Д") + " читаємо: " + ТекстПлана;
	Иначе 
		ТекстСообщения = "На " + Формат(ТекущаяДата(), "ДЛФ=Д") + " план читання не сформовано";
	КонецЕсли;
	
	Результат = Телеграм.sendMessage("-1001227968714", ТекстСообщения);
	
КонецПроцедуры

Процедура ПрочитатьИОбработатьЗапросБоту() Экспорт

	Если ЗапросБоту.ТипОтвета = Перечисления.ТипыОтветовТелеграм.Кнопка Тогда	// Это пришёл запрос доступа

		ДанныеСообщения = Боты.ПолучитьДанныеСообщения(Телеграм.Бот, ЗапросБоту.update_id);
		// ...

		// Найдём админов бота
		Запрос = Новый Запрос;
		Запрос.Текст =
		"//здесь был текст запроса";
		Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДата());
		Результат = Запрос.Выполнить();
		Если Результат.Пустой() Тогда
			Возврат;
		КонецЕсли;

		// Каждому админу отправим запрос на рассмотрение
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			ИдентификаторАкцепта = Боты.СоздатьСессию(Телеграм.Бот, Новый Структура("Действие, Контрагент", "Акцепт", ЗапросБоту.Контрагент));
			ИдентификаторЗапрета = Боты.СоздатьСессию(Телеграм.Бот, Новый Структура("Действие, Контрагент", "Запрет", ЗапросБоту.Контрагент));

			reply_markup = СтрШаблон("{""inline_keyboard"":[[{""text"":""Разрешить"",""callback_data"":""%1""},{""text"":""Отклонить"",""callback_data"":""%2""}]]}", ИдентификаторАкцепта, ИдентификаторЗапрета);
			parse_mode = "Markdown";
			Телеграм.sendMessage(Выборка.Контрагент.Идентификатор, СтрШаблон("Поступил запрос на предоставление доступа от [%1](http://t.me/%2).", ЗапросБоту.Контрагент.ТелеграмИмя, ЗапросБоту.Контрагент.ТелеграмНик), parse_mode,,,, reply_markup);
		КонецЦикла;

		//ИзменитьКлавиатуруСообщения(ЗапросБоту.Чат, ДанныеСообщения.callback_query.message.message_id);	// Удалим кнопку запроса.

	ИначеЕсли ЗапросБоту.ТипОтвета = Перечисления.ТипыОтветовТелеграм.Текст Тогда	
		
		ДанныеСообщения = Боты.ПолучитьДанныеСообщения(Телеграм.Бот, ЗапросБоту.update_id);
		
		Если СокрЛП(ДанныеСообщения.message.text) = "/start"  Тогда
			
			ТекстПлана = ПолучитьТекстПлана(ТекущаяДата());
			
			Если ЗначениеЗаполнено(ТекстПлана) Тогда
				ТекстСообщения = "План читання на сьогодні: " + ТекстПлана;
			Иначе 
				ТекстСообщения = "На " + ТекущаяДата() + " план читання не сформовано";
			КонецЕсли;
			
		Иначе 
			
			ТекстСообщения = "Не відома команда";
			
		КонецЕсли;
		
		Результат = Телеграм.sendMessage(ЗапросБоту.Чат, ТекстСообщения);
		
	КонецЕсли;
	
	Если Результат["ok"] Тогда
		Боты.ЗакрытьСообщение(Телеграм.Бот, ЗапросБоту.update_id);	
	КонецЕсли;

КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
//

// Функция ПолучитьТекстПлана
//
// Описание:
//
//
// Параметры (название, тип, дифференцированное значение)
//
// Возвращаемое значение: 
//
Функция ПолучитьТекстПлана(НаДату) Экспорт 
	
Результат = "";
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	РегулярныеСообщения.Текст КАК Текст
		|ИЗ
		|	Справочник.РегулярныеСообщения КАК РегулярныеСообщения
		|ГДЕ
		|	РегулярныеСообщения.Дата = &НаДату
		|	И РегулярныеСообщения.Вид = ЗНАЧЕНИЕ(Перечисление.ВидыРегулярныхСообщений.ПланЧтения)";
	
	Запрос.УстановитьПараметр("НаДату", НачалоДня(НаДату)); 
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Результат = Выборка.Текст;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции //ПолучитьТекстПлана