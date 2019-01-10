﻿//Преобразует код языка в формат понятный системной фунции Формат()
// Параметры
//  КодЯзыка  	 – Строка – код языка в формате uk/ru
//
// Возвращаемое значение:
//   Строка   	 – код языка в формате ru_RU/uk_UA
//
Функция ОпределитьКодЯзыкаДляФормат(КодЯзыка) Экспорт
	
	Возврат ?(КодЯзыка = "uk","uk_UA","ru_RU");
	
КонецФункции // ОпределитьКодЯзыкаДляФормат()

// Возвращает код языка интерфейса в формате ru/uk
Функция КодЯзыкаИнтерфейса() Экспорт
	
	Возврат ТекущийЯзык().КодЯзыка;
	//Возврат ИнтернетПоддержкаПользователей.КодЯзыкаИнтерфейсаКонфигурацииУНФ();
	
КонецФункции // КодЯзыкаИнтерфейса()
