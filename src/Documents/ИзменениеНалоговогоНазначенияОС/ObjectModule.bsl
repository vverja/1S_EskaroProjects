Перем мУдалятьДвижения;

Перем мВалютаРегламентированногоУчета Экспорт;

Перем мУчетнаяПолитика;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Процедура определяет возможный вид корректировки налогового кредита, по переданным данным
//
// Параметры
//  Данные  – Строка табличной части, структура, строка таблицы. Должна содержать реквизиты (колонки):
//  			НалоговоеНазначение, НалоговоеНазначениеНовое
//
// Возвращаемое значение:
//   ПеречислениеСсылка.ВидыКорректировокНалоговогоКредита  - вид корректировки. Если неопределен - пустая ссылка.
//
Функция ОпределитьВидКорректировкиНК(Данные) Экспорт
	
	Если    НЕ ЗначениеЗаполнено(Данные.НалоговоеНазначение)
		ИЛИ НЕ ЗначениеЗаполнено(Данные.НалоговоеНазначениеНовое) Тогда 
		
		Возврат  Перечисления.ВидыКорректировокНалоговогоКредита.ПустаяСсылка();
		
	КонецЕсли; 
	
	НалоговыйКредитВход  = Данные.НалоговоеНазначение = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_Пропорционально ИЛИ НалоговыйУчетПовтИсп.ЕстьПравоНаНалоговыйКредит(Данные.НалоговоеНазначение);
	НалоговыйКредитВыход = Данные.НалоговоеНазначение = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_Пропорционально ИЛИ НалоговыйУчетПовтИсп.ЕстьПравоНаНалоговыйКредит(Данные.НалоговоеНазначениеНовое);
	
	Если НалоговыйКредитВход = НалоговыйКредитВыход Тогда
		
		Возврат Перечисления.ВидыКорректировокНалоговогоКредита.НетКорректировок;
		
	ИначеЕсли НалоговыйКредитВход И НЕ НалоговыйКредитВыход Тогда
		
		Возврат Перечисления.ВидыКорректировокНалоговогоКредита.ПотеряПраваНаНалоговыйКредит;
		
	Иначе
		
		Возврат Перечисления.ВидыКорректировокНалоговогоКредита.ВосстановлениеПраваНаНалоговыйКредит;
		
	КонецЕсли;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Процедура определяет параметры учетной политики
//
Процедура ПодготовитьПараметрыУчетнойПолитики(СтруктураШапкиДокумента, Отказ, Заголовок)
	
	СтруктураШапкиДокумента.Вставить("ЕстьНалогНаПрибыль" , Ложь);
	СтруктураШапкиДокумента.Вставить("ЕстьНДС"            , Ложь);
	
	Если НЕ ЗначениеЗаполнено(СтруктураШапкиДокумента.Организация) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	мУчетнаяПолитикаНУ = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитикиРегл(Дата, Организация, Ложь);
	
	Если НЕ Отказ Тогда
		
		СтруктураШапкиДокумента.Вставить("ЕстьНалогНаПрибыль" , мУчетнаяПолитикаНУ.СхемаНалогообложения.НалогНаПрибыль = Истина);
		СтруктураШапкиДокумента.Вставить("ЕстьНДС"            , мУчетнаяПолитикаНУ.СхемаНалогообложения.НДС            = Истина);
		
	КонецЕсли;
	
КонецПроцедуры // ПодготовитьПараметрыУчетнойПолитики()

///////////////////////////////////////////////////////////////////////////////
// ДВИЖЕНИЯ ПО РЕГИСТРАМ

// Выполняет движения по регистрам 
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок)

	ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);

	ДвиженияПоРегиструОжидаемыйИПодтвержденныйНДСПродаж(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);
	
	ПроводкиПоНДС(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);

КонецПроцедуры // ДвиженияПоРегистрам

Процедура ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок)

	ДатаДока                      = Дата;
	ТекОрганизация                = СтруктураШапкиДокумента.Организация;
	ПроводкиБУ                    = Движения.Хозрасчетный;
	НазваниеДокумента             = Метаданные().Представление();

	СтоимостьОС = Движения.СтоимостьОСБухгалтерскийУчет;
	ТаблицаДвиженийСтоимость    = СтоимостьОС.Выгрузить();
	
	//Получение данных о видах налоговой деятельности, к которым принадлежат ОС
	УправлениеВнеоборотнымиАктивами.ДополнитьТабличнуюЧастьСведениямиОбОСБухНалогРегл(МоментВремени(), ТекОрганизация, ТаблицаПоОС,
	                                                  СтруктураШапкиДокумента, Отказ, Заголовок);
													  
	ЗапросПараметрыАмортизацииОС = Новый Запрос();
	ЗапросПараметрыАмортизацииОС.УстановитьПараметр("Период", 		МоментВремени());
	ЗапросПараметрыАмортизацииОС.УстановитьПараметр("Организация", 	ТекОрганизация);
	ЗапросПараметрыАмортизацииОС.УстановитьПараметр("СписокОС", 	ОС.ВыгрузитьКолонку("ОсновноеСредство"));
	
	ЗапросПараметрыАмортизацииОС.Текст = "ВЫБРАТЬ
	                                     |	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.СрокПолезногоИспользования,
	                                     |	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ОбъемПродукцииРабот,
	                                     |	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.СрокИспользованияДляВычисленияАмортизации,
	                                     |	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.СтоимостьДляВычисленияАмортизации,
	                                     |	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ОбъемПродукцииРаботДляВычисленияАмортизации,
	                                     |	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ЛиквидационнаяСтоимость,
	                                     |	ПараметрыАмортизацииОСНалоговыйУчетСрезПоследних.СрокПолезногоИспользования КАК СрокПолезногоИспользованияНУ,
	                                     |	ПараметрыАмортизацииОСНалоговыйУчетСрезПоследних.СрокИспользованияДляВычисленияАмортизации КАК СрокИспользованияДляВычисленияАмортизацииНУ,
	                                     |	ПараметрыАмортизацииОСНалоговыйУчетСрезПоследних.СтоимостьДляВычисленияАмортизации КАК СтоимостьДляВычисленияАмортизацииНУ,
	                                     |	ЕстьNULL(ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ОсновноеСредство, ПараметрыАмортизацииОСНалоговыйУчетСрезПоследних.ОсновноеСредство) КАК ОсновноеСредство
	                                     |ИЗ
	                                     |	РегистрСведений.ПараметрыАмортизацииОСБухгалтерскийУчет.СрезПоследних(
	                                     |			&Период,
	                                     |			Организация = &Организация
	                                     |				И ОсновноеСредство В (&СписокОС)) КАК ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних
	                                     |		ПОЛНОЕ СОЕДИНЕНИЕ РегистрСведений.ПараметрыАмортизацииОСНалоговыйУчет.СрезПоследних(
	                                     |				&Период,
	                                     |				Организация = &Организация
	                                     |					И ОсновноеСредство В (&СписокОС)) КАК ПараметрыАмортизацииОСНалоговыйУчетСрезПоследних
	                                     |		ПО ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ОсновноеСредство = ПараметрыАмортизацииОСНалоговыйУчетСрезПоследних.ОсновноеСредство";
	
	ТекПараметрыАмортизацииОС = ЗапросПараметрыАмортизацииОС.Выполнить().Выгрузить();
														  
	Если Отказ Тогда
		
		Возврат
		
	КонецЕсли;
	
	// Подготовим таблицу с данными по амортизации для списания амортизации по направлениям затрат
	ТабАмортизации = Новый ТаблицаЗначений;
	ТабАмортизации.Колонки.Добавить("НаправлениеАмортизации", 	Новый ОписаниеТипов("СправочникСсылка.СпособыОтраженияРасходовПоАмортизации"));
	ТабАмортизации.Колонки.Добавить("Местонахождение", 			Новый ОписаниеТипов("СправочникСсылка.ПодразделенияОрганизаций"));
	ТабАмортизации.Колонки.Добавить("ОбъектУчета", 				Новый ОписаниеТипов("СправочникСсылка.ОсновныеСредства"));
	ТабАмортизации.Колонки.Добавить("Амортизация",				ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 2));
	ТабАмортизации.Колонки.Добавить("АмортизацияНУ",			ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 2));
	ТабАмортизации.Колонки.Добавить("СчетАмортизации", 			Новый ОписаниеТипов("ПланСчетовСсылка.Хозрасчетный"));
	ТабАмортизации.Колонки.Добавить("НалоговоеНазначение", 		Новый ОписаниеТипов("СправочникСсылка.НалоговыеНазначенияАктивовИЗатрат"));
	ТабАмортизации.Колонки.Добавить("ИмяСубконто", 				Новый ОписаниеТипов("Строка",, Новый КвалификаторыСтроки(16)));
	
	Для Каждого СтрокаТЧ Из ТаблицаПоОС Цикл
		
		ТекОС = СтрокаТЧ.ОсновноеСредство;
		
		// начисление амортизации за месяц
		Если    СтрокаТЧ.АмортизацияЗаМесяцБУ > 0 
			ИЛИ СтрокаТЧ.АмортизацияЗаМесяцНУ > 0 Тогда
			 
			НоваяСтрока = ТабАмортизации.Добавить();
			НоваяСтрока.ИмяСубконто = "ОсновныеСредства";
			
			НоваяСтрока.Амортизация             = СтрокаТЧ.АмортизацияЗаМесяцБУ;
			НоваяСтрока.АмортизацияНУ           = СтрокаТЧ.АмортизацияЗаМесяцНУ;
			НоваяСтрока.ОбъектУчета            	= СтрокаТЧ.ОсновноеСредство;
			НоваяСтрока.НаправлениеАмортизации 	= СтрокаТЧ.НаправлениеБУ;
			НоваяСтрока.СчетАмортизации        	= СтрокаТЧ.СчетНачисленияАмортизацииБУ;
			НоваяСтрока.НалоговоеНазначение 	= СтрокаТЧ.НалоговоеНазначение_ОС;
			
		КонецЕсли;
		
		Если СтрокаТЧ.НалоговоеНазначение = СтрокаТЧ.НалоговоеНазначениеНовое ТОгда
			Продолжить;
		КонецЕсли;
		
		// проводки по плану счетов по изменению налогового назначения ОС: первонач. стоимость
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Активность 	= Истина;
		Проводка.Организация 	= ТекОрганизация;
		Проводка.Период 		= ДатаДока;
		
		Проводка.Сумма = СтрокаТЧ.СтоимостьБУ;
		
		Проводка.СчетДт = СтрокаТЧ.СчетУчетаБУ;
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "ОсновныеСредства", ТекОС);
		Проводка.НалоговоеНазначениеДт = СтрокаТЧ.НалоговоеНазначениеНовое;
		
		Проводка.СчетКт = СтрокаТЧ.СчетУчетаБУ;
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "ОсновныеСредства", ТекОС);
		Проводка.НалоговоеНазначениеКт = СтрокаТЧ.НалоговоеНазначение;
		
		Если НЕ Проводка.НалоговоеНазначениеДт = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность Тогда
			Проводка.СуммаНУДт = СтрокаТЧ.СтоимостьНУ;
			Если  СтрокаТЧ.НалоговоеНазначение = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность Тогда
				// восстановим сумму НУ - она указана руками в документе.
				Проводка.СуммаНУДт = СтрокаТЧ.СуммаНУ;	
			КонецЕсли;
		КонецЕсли;
		
		Проводка.СуммаНУКт = СтрокаТЧ.СтоимостьНУ;
		
		// проводки по плану счетов по изменению налогового назначения ОС: накопленная амортизация
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Активность 	= Истина;
		Проводка.Организация 	= ТекОрганизация;
		Проводка.Период 		= ДатаДока;
		
		Проводка.Сумма = СтрокаТЧ.АмортизацияБУ + СтрокаТЧ.АмортизацияЗаМесяцБУ;
		
		Проводка.СчетДт = СтрокаТЧ.СчетНачисленияАмортизацииБУ;
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "ОсновныеСредства", ТекОС);
		Проводка.НалоговоеНазначениеДт = СтрокаТЧ.НалоговоеНазначение;
		
		Проводка.СчетКт = СтрокаТЧ.СчетНачисленияАмортизацииБУ;
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "ОсновныеСредства", ТекОС);
		Проводка.НалоговоеНазначениеКт = СтрокаТЧ.НалоговоеНазначениеНовое;
		
		Проводка.СуммаНУДт = СтрокаТЧ.АмортизацияНУ + СтрокаТЧ.АмортизацияЗаМесяцНУ;
		
		Если НЕ Проводка.НалоговоеНазначениеКт = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность Тогда
			Проводка.СуммаНУКт = СтрокаТЧ.АмортизацияНУ + СтрокаТЧ.АмортизацияЗаМесяцНУ;
		КонецЕсли;
		
		// проводки по корректировке НДС
		Если СтрокаТЧ.МетодКорректировкиНалоговогоКредита = Перечисления.МетодыКорректировкиНалоговогоКредита.НаНалоговыеОбязательства Тогда
			// Проводки по условной продаже  будут сделаны в процедуре ПроводкиПоНДС();
			
		ИначеЕсли СтрокаТЧ.МетодКорректировкиНалоговогоКредита = Перечисления.МетодыКорректировкиНалоговогоКредита.НаНалоговыйКредит Тогда
			
			//Бух учет  - переоцениваем ОС на сумму НДС
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Активность = Истина;
			Проводка.Организация = ТекОрганизация;
			Проводка.Период = ДатаДока;
			
			Проводка.Сумма  = СтрокаТЧ.НДС;
			
			Проводка.СчетКт = СтрокаТЧ.СчетУчетаБУ;
			БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт,"ОсновныеСредства", ТекОС);
			
			Проводка.НалоговоеНазначениеКт = СтрокаТЧ.НалоговоеНазначениеНовое; 
			Если СтруктураШапкиДокумента.ЕстьНалогНаПрибыль Тогда
				Проводка.СуммаНУКт = СтрокаТЧ.НДС;
			КонецЕсли;
			Проводка.СчетДт = СтруктураШапкиДокумента.СчетУчетаКорректировкиНДСКредит;
			
			// пересчитаем начисленную ранее амортизацию по ОС в связи с изменением его стоимости.
			// пересчет осуществим пропорционально уменьшению стоимости.
			КоэффПересчетаАмортизации = - ?(СтрокаТЧ.СтоимостьБУ = 0, 0, СтрокаТЧ.НДС/СтрокаТЧ.СтоимостьБУ);
			
			
			
			НоваяСтрока = ТабАмортизации.Добавить();
			НоваяСтрока.ИмяСубконто = "ОсновныеСредства";
			
			НоваяСтрока.Амортизация 			= КоэффПересчетаАмортизации * (СтрокаТЧ.АмортизацияБУ + СтрокаТЧ.АмортизацияЗаМесяцБУ);
			НоваяСтрока.АмортизацияНУ 			= НалоговыйУчет.ОпределитьСтоимостьНУ(СтрокаТЧ.НалоговоеНазначение, КоэффПересчетаАмортизации * (СтрокаТЧ.АмортизацияНУ + СтрокаТЧ.АмортизацияЗаМесяцНУ));
			НоваяСтрока.ОбъектУчета            	= ТекОС;
			НоваяСтрока.НаправлениеАмортизации 	= СпособОтраженияРасходов;
			НоваяСтрока.СчетАмортизации        	= СтрокаТЧ.СчетНачисленияАмортизацииБУ;
			НоваяСтрока.НалоговоеНазначение 	= СтрокаТЧ.НалоговоеНазначение;
			
			
			// Движения по регистру СтоимостьОС
			Движение = ТаблицаДвиженийСтоимость.Добавить();

			Движение.ОсновноеСредство = ТекОС;
			Движение.Амортизация      = 0;
			Движение.Стоимость        = СтрокаТЧ.НДС;
			Если СтруктураШапкиДокумента.ЕстьНалогНаПрибыль Тогда
				Движение.СтоимостьНУ = СтрокаТЧ.НДС;
			КонецЕсли;
			Движение.Амортизация 		= -КоэффПересчетаАмортизации * (СтрокаТЧ.АмортизацияБУ + СтрокаТЧ.АмортизацияЗаМесяцБУ);
			Движение.АмортизацияНУ 		= НалоговыйУчет.ОпределитьСтоимостьНУ(СтрокаТЧ.НалоговоеНазначение, -КоэффПересчетаАмортизации * (СтрокаТЧ.АмортизацияНУ + СтрокаТЧ.АмортизацияЗаМесяцНУ));
			
			
			
			// Движения по регистру ПараметрыАмортизации - изменена первоначальная стоимость ОС
			СтрокаПараметров = ТекПараметрыАмортизацииОС.Найти(ТекОс, "ОсновноеСредство");
			Если НЕ СтрокаПараметров = Неопределено Тогда
			
				Движение = Движения.ПараметрыАмортизацииОСБухгалтерскийУчет.Добавить();
				
				ЗаполнитьЗначенияСвойств(Движение, СтрокаПараметров);
				
				Движение.Период                                       = ДатаДока;
				Движение.ОсновноеСредство                             = ТекОС;
				Движение.Организация                                  = ТекОрганизация;
				
				Движение.СтоимостьДляВычисленияАмортизации    		  = Движение.СтоимостьДляВычисленияАмортизации - СтрокаТЧ.НДС;
				
				// Движения по регистру ПараметрыАмортизацииНУ - изменена первоначальная стоимость ОС
				Если СтруктураШапкиДокумента.ЕстьНалогНаПрибыль Тогда
					
					Движение = Движения.ПараметрыАмортизацииОСНалоговыйУчет.Добавить();
					
					Движение.Период 									= ДатаДока;
					Движение.ОсновноеСредство 							= ТекОС;
					Движение.Организация 								= ТекОрганизация;
					
					Движение.СрокПолезногоИспользования 				= СтрокаПараметров.СрокПолезногоИспользованияНУ;
					
					Движение.СрокИспользованияДляВычисленияАмортизации 	= СтрокаПараметров.СрокИспользованияДляВычисленияАмортизацииНУ;
					
					Если СтрокаТЧ.НалоговоеНазначение = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность Тогда
						// ОС был непроизводственный, суммы для амортизации в регистре и на счете не было.
						Движение.СтоимостьДляВычисленияАмортизации 		= СтрокаТЧ.СуммаНУ - СтрокаТЧ.НДС;
					Иначе	
						Движение.СтоимостьДляВычисленияАмортизации 		= СтрокаПараметров.СтоимостьДляВычисленияАмортизацииНУ - СтрокаТЧ.НДС;						
					КонецЕсли;
					
				КонецЕсли;
			
			КонецЕсли;
			
		КонецЕсли;
 
		// Движения по регистру НалоговыеНазначенияОС
		Движение = Движения.НалоговыеНазначенияОС.Добавить();
		Движение.Период                   = ДатаДока;
		Движение.ОсновноеСредство         = ТекОС;
		Движение.Организация              = ТекОрганизация;
		Движение.НалоговоеНазначение      = СтрокаТЧ.НалоговоеНазначениеНовое;
		
		// Движения по регистру СобытияОСОрганизаций
		Движение = Движения.СобытияОСОрганизаций.Добавить();
		Движение.Период               = ДатаДока;
		Движение.ОсновноеСредство     = ТекОС;
		Движение.Организация          = ТекОрганизация;
		Движение.Событие              = СтруктураШапкиДокумента.СобытиеРегл;
		Движение.НомерДокумента		  = Номер;
		Движение.НазваниеДокумента 	  = НазваниеДокумента;
		
		// Движения по регистру НачислениеАмортизацииОСНалоговыйУчет
		// при переводе ОС из/в непроизводственное
		Если СтруктураШапкиДокумента.ЕстьНалогНаПрибыль Тогда
			
			Если  СтрокаТЧ.НалоговоеНазначение      = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность 
			 И НЕ СтрокаТЧ.НалоговоеНазначениеНовое = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность Тогда
				
				Движение = Движения.НачислениеАмортизацииОСНалоговыйУчет.Добавить();
				
				Движение.Период               = ДатаДока;
				Движение.ОсновноеСредство     = ТекОС;
				Движение.Организация          = ТекОрганизация;
				Движение.НачислятьАмортизацию = Истина;
			
			ИначеЕсли  НЕ СтрокаТЧ.НалоговоеНазначение      = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность 
				        И СтрокаТЧ.НалоговоеНазначениеНовое = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность Тогда
				
				Движение = Движения.НачислениеАмортизацииОСНалоговыйУчет.Добавить();
				
				Движение.Период               = ДатаДока;
				Движение.ОсновноеСредство     = ТекОС;
				Движение.Организация          = ТекОрганизация;
				Движение.НачислятьАмортизацию = Ложь;
			
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	СтоимостьОС.мПериод          = ДатаДока;
	СтоимостьОС.мТаблицаДвижений = ТаблицаДвиженийСтоимость;
	Движения.СтоимостьОСБухгалтерскийУчет.ВыполнитьРасход();
	
	Если ТабАмортизации <> Неопределено Тогда
		
		// Вызов процедуры списания амортизации по направлениям.
		// Создаются движения по начислению амортизации.
		УправлениеВнеоборотнымиАктивами.ПолучитьРаспределениеАмортизацииПоНаправлениямРегл(ЭтотОбъект,
		                                                   Отказ,
														   Заголовок,
														   ТабАмортизации,
														   СтруктураШапкиДокумента,
														   "ОС");
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ДвиженияПоРегиструОжидаемыйИПодтвержденныйНДСПродаж(СтруктураШапкиДокумента, 
	ПроводкиПоТоварам, Отказ, Заголовок)
	    
	Если НЕ СтруктураШапкиДокумента.ЕстьНДС Тогда
		Возврат;
	КонецЕсли;
	
	// для метода корректировки "На обязательства" отражаем в регистре НДСПродажа, далее в книге продаж
	// отразится документом НалоговаяНалкданая (Вид операции - Условная продажа)
	НаборДвижений = Движения.ОжидаемыйИПодтвержденныйНДСПродаж;
	
	// Получим таблицу значений, совпадающую со струкутрой набора записей регистра.
	ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж = НаборДвижений.ВыгрузитьКолонки();
	
	ТаблицаКопия = ПроводкиПоТоварам.Скопировать();
	
	// оставим только строки с методом корректировки "на обязательства" и ненулевой суммой обязательств
	Инд = 0;
	Пока Инд < ТаблицаКопия.Количество() Цикл
		СтрокаТаблицы = ТаблицаКопия[Инд];
		
		Если  НЕ СтрокаТаблицы.МетодКорректировкиНалоговогоКредита = Перечисления.МетодыКорректировкиНалоговогоКредита.НаНалоговыеОбязательства 
			ИЛИ СтрокаТаблицы.НДС = 0 Тогда
			
			ТаблицаКопия.Удалить(СтрокаТаблицы);
			
		Иначе
			
			Инд = Инд + 1;
			
		КонецЕсли;
	КонецЦикла;
	
	ТаблицаКопия.Колонки.НДС.Имя 	= "СуммаНДС";
	ТаблицаКопия.Свернуть("","СуммаНДС, БазаНДС");
	
	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаКопия, ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж);
	
	ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж.ЗаполнитьЗначения(СтруктураШапкиДокумента.Организация			  , "Организация");
	ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж.ЗаполнитьЗначения(Перечисления.СтавкиНДС.НДС20					  , "СтавкаНДС");
	ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж.ЗаполнитьЗначения(Перечисления.СобытияОжидаемыйИПодтвержденныйНДСПродаж.УсловнаяПродажа  , "СобытиеНДС");
	ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж.ЗаполнитьЗначения(Перечисления.КодыОперацийОжидаемыйИПодтвержденныйНДСПродаж.ОжидаемыйНДС, "КодОперации");
	
	ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж.ЗаполнитьЗначения(Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_Облагаемая, "НалоговоеНазначение");
	
	Если ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж.Количество()>0 Тогда
		
		НаборДвижений.мПериод            = СтруктураШапкиДокумента.Дата;
		НаборДвижений.мТаблицаДвижений   = ТаблицаДвиженийОжидаемыйИПодтвержденныйНДСПродаж;
		
		Если Не Отказ Тогда
			Движения.ОжидаемыйИПодтвержденныйНДСПродаж.ВыполнитьПриход();
		КонецЕсли;
		
	КонецЕсли; 
	
КонецПроцедуры

Процедура ПроводкиПоНДС(СтруктураШапкиДокумента, ПроводкиПоТоварам, Отказ, Заголовок)
	
	Если НЕ СтруктураШапкиДокумента.ЕстьНДС Тогда
		Возврат;
	КонецЕсли;
	
	ПроводкиБУ = Движения.Хозрасчетный;	
	// Проводки по НДС
	
	// Суммы, по корректировкам налоговых обязательств (условная продажа)
	ТаблицаКопия = ПроводкиПоТоварам.Скопировать();
	
	ТаблицаКопия.Свернуть("МетодКорректировкиНалоговогоКредита,НалоговоеНазначениеНовое","НДС");
	
	// оставим только строку с методом корректировки "на обязательства" и ненулевой суммой обязательств
	Инд = 0;
	Пока Инд < ТаблицаКопия.Количество() Цикл
		СтрокаТаблицы = ТаблицаКопия[Инд];
		
		Если  НЕ СтрокаТаблицы.МетодКорректировкиНалоговогоКредита = Перечисления.МетодыКорректировкиНалоговогоКредита.НаНалоговыеОбязательства 
			ИЛИ СтрокаТаблицы.НДС = 0 Тогда
			
			ТаблицаКопия.Удалить(СтрокаТаблицы);
			
		Иначе
			
			Инд = Инд + 1;
			
		КонецЕсли;
	КонецЦикла;	
	
	Для Каждого СтрокаТаблицы Из ТаблицаКопия Цикл
	
		Проводка = ПроводкиБУ.Добавить();
		
		Проводка.Период                     = СтруктураШапкиДокумента.Дата;
		Проводка.Активность                 = Истина;
		Проводка.Организация                = СтруктураШапкиДокумента.Организация;
		
		Проводка.Сумма                      = СтрокаТаблицы.НДС;
		
		Проводка.СчетДт						= СтруктураШапкиДокумента.СчетУчетаЗатрат;
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 1 , СтруктураШапкиДокумента.ЗатратыСубконто1);
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 2 , СтруктураШапкиДокумента.ЗатратыСубконто2);
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 3 , СтруктураШапкиДокумента.ЗатратыСубконто3);
		
		Если СтруктураШапкиДокумента.ЕстьНалогНаПрибыль Тогда
			Если СтрокаТаблицы.НалоговоеНазначениеНовое = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_НеоблагаемаяНеХозДеятельность  Тогда
				
				Проводка.НалоговоеНазначениеДт = Справочники.НалоговыеНазначенияАктивовИЗатрат.НКУ_НеХозДеятельность;
				
			Иначе	
				
				Проводка.НалоговоеНазначениеДт = СтруктураШапкиДокумента.НалоговоеНазначениеДоходовИЗатрат;
				Если НЕ СтруктураШапкиДокумента.НалоговоеНазначениеДоходовИЗатрат = Справочники.НалоговыеНазначенияАктивовИЗатрат.НКУ_НеХозДеятельность Тогда
					
					Проводка.СуммаНУДт =  СтрокаТаблицы.НДС;
				
				КонецЕсли;
				
			КонецЕсли;
		КонецЕсли;
		
		Проводка.СчетКт						= СтруктураШапкиДокумента.СчетУчетаНДС_НО;
		
		Проводка.Содержание					= НСтр("ru='Налоговые обязательства по НДС (условная продажа)';uk=""Податкові зобов'язання по ПДВ (умовний продаж)""",Локализация.КодЯзыкаИнформационнойБазы());
		
	КонецЦикла;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОВЕРКИ ПРАВИЛЬНОСТИ ЗАПОЛНЕНИЯ

Процедура ПроверитьЗаполнениеМетодКорректировкиНалоговогоКредитаВТабличнойЧасти(Таблица, ИмяТабличнойЧасти, Отказ, Заголовок)
	
	ПредставлениеТабличнойЧасти = Метаданные().ТабличныеЧасти[ИмяТабличнойЧасти].Представление();
	
	Для каждого СтрокаТЧ  Из Таблица Цикл
		
		СтрокаНачалаСообщенияОбОшибке = Локализация.СтрШаблон(НСтр("ru='В строке номер ""¤1¤"": ';uk='У рядку номер ""¤1¤"": '"), СокрЛП(СтрокаТЧ.НомерСтроки));
		СтрокаСообщения = НСтр("ru='Неверное значение метода корректировки налогового кредита (""Метод корректировки"")!';uk='Невірне значення методу коригування податкового кредиту (""Метод коригування"")!'");	
		
		Если (  СтрокаТЧ.ВидКорректировкиНалоговогоКредита = Перечисления.ВидыКорректировокНалоговогоКредита.ВосстановлениеПраваНаНалоговыйКредит
			И СтрокаТЧ.МетодКорректировкиНалоговогоКредита = Перечисления.МетодыКорректировкиНалоговогоКредита.НаНалоговыеОбязательства)
			ИЛИ 
			(  СтрокаТЧ.ВидКорректировкиНалоговогоКредита = Перечисления.ВидыКорректировокНалоговогоКредита.ПотеряПраваНаНалоговыйКредит
			И СтрокаТЧ.МетодКорректировкиНалоговогоКредита = Перечисления.МетодыКорректировкиНалоговогоКредита.НаНалоговыйКредит)	
			ИЛИ 
			(     СтрокаТЧ.ВидКорректировкиНалоговогоКредита = Перечисления.ВидыКорректировокНалоговогоКредита.НетКорректировок
			И НЕ СтрокаТЧ.МетодКорректировкиНалоговогоКредита = Перечисления.МетодыКорректировкиНалоговогоКредита.НеКорректировать)	 Тогда
			
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + СтрокаСообщения, Отказ, Заголовок);
			
		КонецЕсли;
		
	КонецЦикла; 
	
КонецПроцедуры 

////////////////////////////////////////////////////////////////////////////////
// ПРОВЕРКИ ПРАВИЛЬНОСТИ ЗАПОЛНЕНИЯ

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизтов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверяется также правильность заполнения реквизитов ссылочных полей документа.
// Проверка выполняется по объекту и по выборке из результата запроса по шапке.
//
// Параметры: 
//  СтруктураШапкиДокумента - структура, содержащая рексвизиты шапки документа и результаты запроса по шапке,
//  Отказ                   - флаг отказа в проведении,
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)
	
	СтруктураОбязательныхПолей = Новый Структура("Организация, СобытиеРегл");
	
	СтруктураОбязательныхПолей.Вставить("СчетУчетаНДС_НО");
	СтруктураОбязательныхПолей.Вставить("СчетУчетаЗатрат");
	СтруктураОбязательныхПолей.Вставить("СчетУчетаКорректировкиНДСКредит");
	СтруктураОбязательныхПолей.Вставить("СпособОтраженияРасходов");
	
	Если СтруктураШапкиДокумента.ЕстьНалогНаПрибыль Тогда
		СтруктураОбязательныхПолей.Вставить("НалоговоеНазначениеДоходовИЗатрат");
			
		//проверим указание субконто для заполнения декларации по прибыли
		Если ЗначениеЗаполнено(СчетУчетаЗатрат) Тогда
			
			ЕстьСубконтоСтатьяЗатратДоходов = Ложь;
			Для НомСубконто = 1 По 3 Цикл
				Если СчетУчетаЗатрат.ВидыСубконто.Количество()<НомСубконто Тогда
					Прервать;
				КонецЕсли;
				
				ВидСубконто = СчетУчетаЗатрат.ВидыСубконто[НомСубконто-1].ВидСубконто;
				Если     ВидСубконто = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.СтатьиЗатрат
					 ИЛИ ВидСубконто = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.СтатьиДоходов
					 ИЛИ ВидСубконто = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.СтатьиНеоперационныхРасходов Тогда
					ЕстьСубконтоСтатьяЗатратДоходов = Истина;
					Прервать;
				КонецЕсли;

			КонецЦикла;
			
			Если ЕстьСубконтоСтатьяЗатратДоходов Тогда
				СтруктураОбязательныхПолей.Вставить("ЗатратыСубконто" + НомСубконто, НСТР("ru = 'Не заполнено значение субконто: '; uk = 'Не заповнене значення субконто: '") + ВидСубконто); 	
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Теперь позовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строк табличной части "Товары".
//
// Параметры:
// Параметры: 
//  ТаблицаПоТоварам        - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  СтруктураШапкиДокумента - структура, содержащая рексвизиты шапки документа и результаты запроса по шапке
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиОС(ТаблицаПоОС, СтруктураШапкиДокумента, Отказ, Заголовок)
	
	ИмяТабличнойЧасти = "ОС";
	
	СтруктураОбязательныхПолей = Новый Структура("ОсновноеСредство, НалоговоеНазначение, НалоговоеНазначениеНовое");
	
	Если СтруктураШапкиДокумента.ЕстьНДС Тогда
		
		СтруктураОбязательныхПолей.Вставить("МетодКорректировкиНалоговогоКредита");
		
	КонецЕсли; 
	
	ПроверитьВозможностьКорректировки(ТаблицаПоОС, ИмяТабличнойЧасти, Отказ, Заголовок);
	
	Если НЕ Отказ Тогда
		ПроверитьЗаполнениеМетодКорректировкиНалоговогоКредитаВТабличнойЧасти(ТаблицаПоОС, ИмяТабличнойЧасти, Отказ, Заголовок);
	КонецЕсли;
	
	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "ОС", СтруктураОбязательныхПолей, Отказ, Заголовок);
	
КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

Процедура ПроверитьВозможностьКорректировки(Таблица, ИмяТабличнойЧасти, Отказ, Заголовок)

	ПредставлениеТабличнойЧасти = Метаданные().ТабличныеЧасти[ИмяТабличнойЧасти].Представление();
	
	ПропорцНДС = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_Пропорционально;
	ОблНДС	   = Справочники.НалоговыеНазначенияАктивовИЗатрат.НДС_Облагаемая;
	
	Для каждого СтрокаТЧ  Из Таблица Цикл
		
		СтрокаНачалаСообщенияОбОшибке = Локализация.СтрШаблон(НСтр("ru='В строке номер ""¤1¤"": ';uk='У рядку номер ""¤1¤"": '"), СокрЛП(СтрокаТЧ.НомерСтроки));
		СтрокаСообщения = НСтр("ru = 'Корректировка между указанными налоговыми назначениями не предусмотрена!'; uk = 'Коригування між вказаними податковими призначеннями не предусмотрена!'");	
		
		ВыдаватьСообщение = Ложь;
		
		Если СтрокаТЧ.НалоговоеНазначениеНовое = ПропорцНДС Тогда
		
			ВыдаватьСообщение = Истина;
			
		ИначеЕсли СтрокаТЧ.НалоговоеНазначение      = ПропорцНДС 
			    И СтрокаТЧ.НалоговоеНазначениеНовое = ОблНДС Тогда
			
			ВыдаватьСообщение = Истина;
			
		КонецЕсли;
		
		
		Если ВыдаватьСообщение Тогда
			
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + СтрокаСообщения, Отказ, Заголовок);
			
		КонецЕсли;
		
	КонецЦикла; 		

КонецПроцедуры

// Процедура формирует таблицы документа.
//
Процедура ПодготовитьТаблицыДокумента(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок) Экспорт
	
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("ОсновноеСредство"    , "ОсновноеСредство");
	СтруктураПолей.Вставить("СтоимостьБУ"         , "СтоимостьБУ");
	СтруктураПолей.Вставить("АмортизацияБУ"       , "АмортизацияБУ");
	СтруктураПолей.Вставить("АмортизацияЗаМесяцБУ", "АмортизацияЗаМесяцБУ");
	СтруктураПолей.Вставить("СтоимостьНУ"         , "СтоимостьНУ");
	СтруктураПолей.Вставить("АмортизацияНУ"       , "АмортизацияНУ");
	СтруктураПолей.Вставить("АмортизацияЗаМесяцНУ", "АмортизацияЗаМесяцНУ");
	СтруктураПолей.Вставить("НДС"				  , "СуммаНДС");
	СтруктураПолей.Вставить("НалоговоеНазначение" , "НалоговоеНазначение");
	СтруктураПолей.Вставить("НалоговоеНазначениеНовое", "НалоговоеНазначениеНовое");
	СтруктураПолей.Вставить("МетодКорректировкиНалоговогоКредита", "МетодКорректировкиНалоговогоКредита");
	СтруктураПолей.Вставить("СуммаНУ"			  , "СуммаНУ");

	РезультатЗапросаПоОС = УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "ОС", СтруктураПолей);
	
	// Подготовим таблицы товаров для проведения.
	ТаблицаПоОС = ПодготовитьТаблицуОС(РезультатЗапросаПоОС, СтруктураШапкиДокумента);
	
КонецПроцедуры

Функция ПодготовитьТаблицуОС(РезультатЗапросаПоОС, СтруктураШапкиДокумента)
	
	ТаблицаОС = РезультатЗапросаПоОС.Выгрузить();
	
	ТаблицаОС.Колонки.Добавить("ВидКорректировкиНалоговогоКредита",Новый ОписаниеТипов("ПеречислениеСсылка.ВидыКорректировокНалоговогоКредита"));
	ТаблицаОС.Колонки.Добавить("БазаНДС", 							ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,2));
	
	Для каждого СтрокаТаблицы Из ТаблицаОС Цикл
		
		СтрокаТаблицы.ВидКорректировкиНалоговогоКредита = ОпределитьВидКорректировкиНК(СтрокаТаблицы);
		СтрокаТаблицы.БазаНДС  = СтрокаТаблицы.НДС*100/Ценообразование.ПолучитьСтавкуНДС(Перечисления.СтавкиНДС.НДС20);
		
	КонецЦикла;
	
	Возврат ТаблицаОС;
	
КонецФункции // ПодготовитьТаблицуОС()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура вызывается перед записью документа 
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	мУдалятьДвижения = НЕ ЭтоНовый();
	
КонецПроцедуры // ПередЗаписью

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Перем Заголовок, СтруктураШапкиДокумента;
	Перем ТаблицаПоОС;

	Если мУдалятьДвижения Тогда
    	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(СтруктураШапкиДокумента);
		
	// Получим данные учетной политики
	ПодготовитьПараметрыУчетнойПолитики(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);

    ПодготовитьТаблицыДокумента(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);

	// Проверить заполнение ТЧ 
	ПроверитьЗаполнениеТабличнойЧастиОС(ТаблицаПоОС, СтруктураШапкиДокумента, Отказ, Заголовок);
	
	Если Отказ Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если НЕ (СтруктураШапкиДокумента.ЕстьНДС) Тогда
		
		ОбщегоНазначения.СообщитьОбОшибке(Локализация.СтрШаблон("На дату документа: ¤1¤ организация ""¤2¤""¤3¤не является плательщиком налога на прибыль или НДС.¤4¤В этом случае документ не используется.", Формат(Дата, "ДЛФ=D"+";Л="+Локализация.ОпределитьКодЯзыкаДляФормат(Локализация.КодЯзыкаИнтерфейса())), Организация, Символы.ПС, Символы.ПС),
						Отказ, Заголовок);
		Возврат;				
						
	КонецЕсли;
	
	//проверка, нет ли списанных ОС в табличной части
	УправлениеВнеоборотнымиАктивами.ПроверитьНаСписанность(Дата, Организация, ТаблицаПоОС, Ложь, Истина, Отказ, Заголовок);
	
    УправлениеВнеоборотнымиАктивами.ПроверитьДублированиеОСиНМАвТабличнойЧасти(ОС, "ОсновноеСредство", "Основное средство", Отказ, Заголовок);

	Если Не Отказ Тогда
		
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);
		
	КонецЕсли;
	
КонецПроцедуры // ОбработкаПроведения()


Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить()