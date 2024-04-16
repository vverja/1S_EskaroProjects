////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

Функция СформироватьЗапросПоШапке(Режим)

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка" , Ссылка);

	Запрос.Текст = "ВЫБРАТЬ
	               |	ИсполнительныйЛист.Дата,
	               |	ИсполнительныйЛист.Организация,
	               |	ИсполнительныйЛист.Сотрудник,
	               |	ИсполнительныйЛист.ДатаДействия,
	               |	ИсполнительныйЛист.ДатаОкончания,
	               |	ИсполнительныйЛист.Размер,
	               |	ИсполнительныйЛист.Предел,	               
	               |	ИсполнительныйЛист.СпособРасчетаИЛ,
	               |	ИсполнительныйЛист.Получатель,
	               |	ИсполнительныйЛист.ВидИсполнительногоДокумента,
	               |	ИсполнительныйЛист.Ссылка
	               |ИЗ
	               |	Документ.ИсполнительныйЛист КАК ИсполнительныйЛист
	               |
	               |ГДЕ
	               |	ИсполнительныйЛист.Ссылка = &ДокументСсылка";

	Возврат Запрос.Выполнить();

КонецФункции // СформироватьЗапросПоШапке()

Процедура ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ)

	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.Организация) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указана организация!", Отказ);
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.Сотрудник) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указан работник!", Отказ);
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.ДатаДействия) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указана дата действия удержания!", Отказ);
	КонецЕсли;
	
	// Получатель
	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.Получатель) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указан получатель!", Отказ);
	КонецЕсли;
	
КонецПроцедуры // ПроверитьЗаполнениеШапки()

Процедура ДобавитьСтрокуВДвиженияПоРегистрамСведений(ВыборкаПоШапкеДокумента)

	// Движения регистра ПлановыеУдержанияРаботниковОрганизаций
	
	// Определим вид расчета
	Если ВыборкаПоШапкеДокумента.ВидИсполнительногоДокумента = "Исполнительный лист"
		И ВыборкаПоШапкеДокумента.СпособРасчетаИЛ = 1 Тогда
		// Процентом
		
		Если ВыборкаПоШапкеДокумента.Предел = 0 Тогда
			ВидРасчета = ПланыВидовРасчета.УдержанияОрганизаций.ИЛПроцентом;
		Иначе	
			ВидРасчета = ПланыВидовРасчета.УдержанияОрганизаций.ИЛПроцентомДоПредела;
		КонецЕсли; 
		
	ИначеЕсли ВыборкаПоШапкеДокумента.ВидИсполнительногоДокумента = "Исполнительный лист" Тогда
		// Фикс суммой	
		
		Если ВыборкаПоШапкеДокумента.Предел = 0 Тогда
			ВидРасчета = ПланыВидовРасчета.УдержанияОрганизаций.ИЛФиксированнойСуммой;
		Иначе	
			ВидРасчета = ПланыВидовРасчета.УдержанияОрганизаций.ИЛФиксированнойСуммойДоПредела;
		КонецЕсли; 
		
	ИначеЕсли ВыборкаПоШапкеДокумента.СпособРасчетаИЛ = 1 Тогда
		// Алименты Процентом
		
		Если ВыборкаПоШапкеДокумента.Предел = 0 Тогда
			ВидРасчета = ПланыВидовРасчета.УдержанияОрганизаций.АлиментыПроцентом;
		Иначе	
			ВидРасчета = ПланыВидовРасчета.УдержанияОрганизаций.АлиментыПроцентомДоПредела;
		КонецЕсли; 
		
	Иначе
		// АлиментыФикс суммой	
		
		Если ВыборкаПоШапкеДокумента.Предел = 0 Тогда
			ВидРасчета = ПланыВидовРасчета.УдержанияОрганизаций.АлиментыФиксированнойСуммой;
		Иначе	
			ВидРасчета = ПланыВидовРасчета.УдержанияОрганизаций.АлиментыФиксированнойСуммойДоПредела;
		КонецЕсли; 
		
	КонецЕсли;  
	
	Движение = Движения.ПлановыеУдержанияРаботниковОрганизаций.Добавить();
	// свойства
	Движение.Период             = ВыборкаПоШапкеДокумента.ДатаДействия;

	// измерения
	Движение.Организация        = ВыборкаПоШапкеДокумента.Организация;
	Движение.Сотрудник			= ВыборкаПоШапкеДокумента.Сотрудник;
	Движение.ВидРасчета         = ВидРасчета;
	
	Движение.ДокументОснование	= ВыборкаПоШапкеДокумента.Ссылка;

	// ресурсы
	Движение.Действие           = Перечисления.ВидыДействияСНачислением.Начать;
	Движение.Показатель1		= ВыборкаПоШапкеДокумента.Размер;
	
	// Если у документа указана дата окончания его действия, то закроем датой окончания это удержание
	Если ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.ДатаОкончания) Тогда
		Движение = Движения.ПлановыеУдержанияРаботниковОрганизаций.Добавить();
		// свойства
		Движение.Период             = КонецДня(ВыборкаПоШапкеДокумента.ДатаОкончания);

		// измерения
		Движение.Организация        = ВыборкаПоШапкеДокумента.Организация;
		Движение.Сотрудник			= ВыборкаПоШапкеДокумента.Сотрудник;
		Движение.ВидРасчета         = ВидРасчета;
		
		Движение.ДокументОснование	= ВыборкаПоШапкеДокумента.Ссылка;

		// ресурсы
		Движение.Действие           = Перечисления.ВидыДействияСНачислением.Прекратить;
		Движение.Показатель1		= 0;		
	КонецЕсли;
	
	Если (СпособПеречисления=Перечисления.СпособыПеречисленияСуммПоИсполнительнымЛистам.ПочтовымПереводом) И (ТарифПочты<>Неопределено) Тогда
		
		Движение = Движения.ПлановыеУдержанияРаботниковОрганизаций.Добавить();
		// свойства
		Движение.Период             = ВыборкаПоШапкеДокумента.ДатаДействия;
		
		// измерения
		Движение.Организация        = ВыборкаПоШапкеДокумента.Организация;
		Движение.Сотрудник          = ВыборкаПоШапкеДокумента.Сотрудник;
		Движение.ВидРасчета         = ПланыВидовРасчета.УдержанияОрганизаций.ПочтовыйСбор;
		
		Движение.ДокументОснование	= ВыборкаПоШапкеДокумента.Ссылка;
		
		// ресурсы
		Движение.Действие           = Перечисления.ВидыДействияСНачислением.Начать;
		Движение.Показатель1				= 0;//ООП 21104 ВыборкаПоШапкеДокумента.Размер;
		
		// Если у документа указана дата окончания его действия, то закроем и "почтовые тарифы"
		Если ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.ДатаОкончания) Тогда
			Движение = Движения.ПлановыеУдержанияРаботниковОрганизаций.Добавить();
			// свойства
			Движение.Период             = КонецДня(ВыборкаПоШапкеДокумента.ДатаОкончания);
			
			// измерения
			Движение.Организация        = ВыборкаПоШапкеДокумента.Организация;
			Движение.Сотрудник          = ВыборкаПоШапкеДокумента.Сотрудник;
			Движение.ВидРасчета         = ПланыВидовРасчета.УдержанияОрганизаций.ПочтовыйСбор;
			
			Движение.ДокументОснование	= ВыборкаПоШапкеДокумента.Ссылка;
			
			// ресурсы
			Движение.Действие           = Перечисления.ВидыДействияСНачислением.Прекратить;
			Движение.Показатель1				= 0;	
		КонецЕсли;
		
	КонецЕсли;
	
		
КонецПроцедуры // ДобавитьСтрокуВДвиженияПоРегистрамСведений

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, Режим)
	РезультатЗапросаПоШапке = СформироватьЗапросПоШапке(Режим);

	// Получим реквизиты шапки из запроса
	ВыборкаПоШапкеДокумента = РезультатЗапросаПоШапке.Выбрать();

	Если ВыборкаПоШапкеДокумента.Следующий() Тогда

		//Надо позвать проверку заполнения реквизитов шапки
		ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ);

		// Движения стоит добавлять, если в проведении еще не отказано (отказ =ложь)
		Если НЕ Отказ Тогда

			Если НЕ Отказ Тогда
				// Заполним записи в наборах записей регистров
				ДобавитьСтрокуВДвиженияПоРегистрамСведений(ВыборкаПоШапкеДокумента);
			КонецЕсли;
			
		КонецЕсли; 

	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	ПроцедурыУправленияПерсоналом.ЗаполнитьФизЛицо(ЭтотОбъект);
	
КонецПроцедуры

