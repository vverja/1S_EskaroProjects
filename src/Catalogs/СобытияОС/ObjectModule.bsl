////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ

// Функция проверяет, были ли движения по регистру 
// с текущим событием
//
Функция БылиДвиженияПоРегистрам()

	Запрос       = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	 |	СобытияОС.Событие
	 |ИЗ
	 |	РегистрСведений.СобытияОС КАК СобытияОС
	 |ГДЕ
	 |	СобытияОС.Событие = &Событие
	 |
	 |ОБЪЕДИНИТЬ ВСЕ
	 |
	 |ВЫБРАТЬ ПЕРВЫЕ 1
	 |	СобытияОСОрганизаций.Событие
	 |ИЗ
	 |	РегистрСведений.СобытияОСОрганизаций КАК СобытияОСОрганизаций
	 |ГДЕ
	 |	СобытияОСОрганизаций.Событие = &Событие";
	
	Запрос.УстановитьПараметр("Событие", Ссылка);
	
	Возврат НЕ Запрос.Выполнить().Пустой();

КонецФункции // БылиДвиженияПоРегистру()

// Процедура проверяет, существуют ли движения в регистрах по данному
// элементу справочника. Если существуют и изменялись определенные реквизиты,
// то запрещает запись.
Процедура ПроверитьВозможностьЗаписиЭлемента(Отказ, Заголовок)

	Если ЭтоНовый() или ОбменДанными.Загрузка Тогда
		
		// Проверять нечего
		Возврат
		
	КонецЕсли;
	
	// Получение старых значений
	ВидСобытияОССтарый  = Ссылка.ВидСобытияОС;
	// Проверка изменений
	ИзмененВидСобытияОС = (ВидСобытияОС <> ВидСобытияОССтарый);
	
	Если ИзмененВидСобытияОС Тогда
		
		Если БылиДвиженияПоРегистрам() Тогда
			
			Сообщение = "" + Символы.Таб + "Нельзя изменять ""Вид события ОС"","
					+ "потому что были движения по регистрам ""События основного средства...""."
					+ Символы.ПС + Символы.Таб + "Текущее значение <" + ВидСобытияОС + "> изменяется на старое <"
					+ ВидСобытияОССтарый + ">.";
			ОбщегоНазначения.СообщитьОбОшибке(Сообщение, Отказ, Заголовок);
			ВидСобытияОС = ВидСобытияОССтарый
		
		КонецЕсли;
	   
		
	КонецЕсли;

КонецПроцедуры // ПроверитьВозможностьЗаписиЭлемента()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ПередЗаписью(Отказ)
	
	Заголовок = "Запись элемента справочника """ + Метаданные().Представление() 
	            + """ Наим: <" + Наименование + "> код: <" + Код + ">:";
				
	ПроверитьВозможностьЗаписиЭлемента(Отказ, Заголовок)
	
КонецПроцедуры

