#ЕСЛИ КЛИЕНТ ТОГДА
Функция СформироватьТекстЗапросаНЗП() 
	ТекстЗапроса = "
	|	ВЫБРАТЬ
	|		РегНЗП.Затрата,
	|		РегНЗП.ХарактеристикаЗатраты,
	|		0,
	|		0,
	|		0,
	|		РегНЗП.КоличествоОстаток
	|	ИЗ
	|		РегистрНакопления.НезавершенноеПроизводство.Остатки(&ДатаКон, Заказ = &Заказ И
	|			((Затрата,ХарактеристикаЗатраты) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента))) КАК РегНЗП";

	Возврат ТекстЗапроса;
КонецФункции

Функция СформироватьТекстЗапросаНЗП_РасширеннаяАналитика(ВидОтраженияВУчете)
	
	ТекстЗапроса = "
	|	ВЫБРАТЬ
	|		РегистрАналитикаУчетаЗатрат.Затрата,
	|		РегистрАналитикаУчетаЗатрат.ХарактеристикаЗатраты,
	|		0,
	|		0,
	|		0,
	|		ЗатратыНаВыпуск.КоличествоОстаток
	|	ИЗ
	|		РегистрНакопления.УчетЗатрат%СуффиксРегл%.Остатки(&ДатаКон, 
	|			АналитикаВидаУчета В (
	|				ВЫБРАТЬ
	|					Ссылка
	|				ИЗ
	|					РегистрСведений.АналитикаВидаУчета КАК РегистрАналитикаВидаУчета
	|				ГДЕ
	|					РазделУчета = ЗНАЧЕНИЕ(Перечисление.РазделыУчета.Затраты)
	|				)
	|			И АналитикаУчетаЗатрат В (
	|				ВЫБРАТЬ
	|					Ссылка
	|				ИЗ
	|					РегистрСведений.АналитикаУчетаЗатрат КАК РегистрАналитикаУчетаЗатрат
	|				ГДЕ
	|				(Затрата,ХарактеристикаЗатраты) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента)
	|				)
	|			И АналитикаУчетаПартий В (
	|				ВЫБРАТЬ
	|					Ссылка
	|				ИЗ
	|					РегистрСведений.АналитикаУчетаПартий КАК РегистрАналитикаУчетаПартий
	|				ГДЕ
	|					Заказ = &Заказ
	|				)
	|		) КАК ЗатратыНаВыпуск
    |	ВНУТРЕННЕЕ СОЕДИНЕНИЕ
	|		РегистрСведений.АналитикаУчетаЗатрат КАК РегистрАналитикаУчетаЗатрат
	|	ПО
	|		ЗатратыНаВыпуск.АналитикаУчетаЗатрат = РегистрАналитикаУчетаЗатрат.Ссылка ";
	
	
	ТекстЗапроса = УправлениеЗатратами.ЗаменитьКомментарииВТекстеЗапроса(
		ТекстЗапроса,
		ВидОтраженияВУчете
	);

    Возврат ТекстЗапроса;
КонецФункции

	
Процедура ОбновитьОтчет(ТабДокумент) Экспорт
	
	ТабДокумент.Очистить();
	флЗаказВыполнен = истина;
	
	// Вывод данных о продукции и полуфабрикатах.
	ТекстЗапроса = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	РегЗаказы.Подразделение КАК Подразделение,
	|	РегЗаказы.Номенклатура КАК Номенклатура,
	|	РегЗаказы.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|	ПРЕДСТАВЛЕНИЕ(РегЗаказы.Подразделение) КАК ПечПодразделение,
	|	ПРЕДСТАВЛЕНИЕ(РегЗаказы.Номенклатура) КАК ПечНоменклатура,
	|	ПРЕДСТАВЛЕНИЕ(РегЗаказы.ХарактеристикаНоменклатуры) КАК ПечХарактеристикаНоменклатуры,
	|	РегЗаказы.Номенклатура.ЕдиницаХраненияОстатков КАК ЕдИзм,
	|	ПРЕДСТАВЛЕНИЕ(РегЗаказы.Номенклатура.ЕдиницаХраненияОстатков) КАК ПечЕдИзм,
	|	ЕСТЬNULL(РегЗаказы.КоличествоПриход, 0) КАК Заказано,
	|	ЕСТЬNULL(РегЗаказы.КоличествоРасход, 0) КАК Отгружено,
	|	ЕСТЬNULL(РегЗаказы.КоличествоКонечныйОстаток, 0) КАК ОсталосьОтгрузить
	|ИЗ
	|	РегистрНакопления.ЗаказыНаПроизводство.ОстаткиИОбороты(&ДатаНач, &ДатаКон, , , ЗаказНаПроизводство = &Заказ) КАК РегЗаказы
	|ИТОГИ
	|	СУММА(Заказано),
	|	СУММА(Отгружено),
	|	СУММА(ОсталосьОтгрузить)
	|ПО
	|	Подразделение,
	|	Номенклатура, ХарактеристикаНоменклатуры
	|	ЕдИзм";
	
	ВидимостьНЗП = Ложь;
	Если глЗначениеПеременной("ИспользоватьПотребностиЗаказовНаПроизводство")
		И глЗначениеПеременной("СпособЗакрытияПотребностейЗаказовНаПроизводство") = Перечисления.СпособыЗакрытияПотребностейЗаказовНаПроизводство.АвтоматическиПриРаспределении Тогда
		
		ВидимостьНЗП = Истина;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	
	Запрос.УстановитьПараметр( "Заказ", Заказ);
	Запрос.УстановитьПараметр( "ДатаНач", Новый Граница( Заказ.Дата, ВидГраницы.Включая));
	Если КонДата = '00010101000000' Тогда
		Запрос.УстановитьПараметр( "ДатаКон", КонДата);
	ИначеЕсли КонецДня(КонДата)<КонецДня(Заказ.Дата) Тогда
		Запрос.УстановитьПараметр( "ДатаКон", '00010101000000');
	Иначе	
		Запрос.УстановитьПараметр( "ДатаКон", Новый Граница( КонецДня(КонДата), ВидГраницы.Включая));
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	// Формирование печатной формы
	Макет = ПолучитьМакет("АнализЗаказа");
	Область = Макет.ПолучитьОбласть("Заголовок");
	Область.Параметры.ТекстЗаголовок = "Состояние: " + ОбщегоНазначения.СформироватьЗаголовокДокумента(Заказ);
	ТабДокумент.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("ТабШапка");
	ТабДокумент.Вывести(Область);
	
	Область1 = Макет.ПолучитьОбласть("СтрокаУровень1");
	Область2 = Макет.ПолучитьОбласть("СтрокаУровень2");
	
	ОбходПодр = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ОбходПодр.Следующий() Цикл
		
		Область1.Параметры.ПечПодразделение    = ?(ПустаяСтрока(ОбходПодр.ПечПодразделение), "Не указано", ОбходПодр.ПечПодразделение);
		Область1.Параметры.Подразделение       = ОбходПодр.Подразделение;
		ТабДокумент.Вывести(Область1);
	
		ОбходНоменклатура = ОбходПодр.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ОбходНоменклатура.Следующий() Цикл
		
			ОбходХарактеристика = ОбходНоменклатура.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ОбходХарактеристика.Следующий() Цикл
				Обход = ОбходХарактеристика.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока Обход.Следующий() Цикл
					Область2.Параметры.ПечНоменклатура = Обход.ПечНоменклатура+?(ЗначениеЗаполнено(Обход.ПечХарактеристикаНоменклатуры)," ("+Обход.ПечХарактеристикаНоменклатуры+")","");;
					Область2.Параметры.Номенклатура    = Обход.Номенклатура;
					Область2.Параметры.ПечЕдИзм        = Обход.ПечЕдИзм;
					Область2.Параметры.ЕдИзм           = Обход.ЕдИзм;
					
					Область2.Параметры.Заказано            = Обход.Заказано;
					Область2.Параметры.Отгружено           = Обход.Отгружено;
					Область2.Параметры.ОсталосьОтгрузить   = Обход.ОсталосьОтгрузить;
					Если Обход.ОсталосьОтгрузить <> 0 Тогда
						флЗаказВыполнен = ложь;
					КонецЕсли;
					
					ТабДокумент.Вывести(Область2);
				КонецЦикла;	
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Область = Макет.ПолучитьОбласть("ТабНиз");
	ТабДокумент.Вывести(Область);
	
	//временная таблица для заполнения массива номенклатуры
	МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
    ЗапросПотребности = Новый Запрос;
    ЗапросПотребности.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
    ЗапросПотребности.Текст = " ВЫБРАТЬ
	|		РегПотребности.Номенклатура КАК Материал,
	|		РегПотребности.ХарактеристикаНоменклатуры КАК ХарактеристикаМатериала,
	|		РегПотребности.Номенклатура.ЕдиницаХраненияОстатков КАК ЕдИзм,
	|		РегПотребности.КоличествоОстаток КАК КолПотребность
	|ПОМЕСТИТЬ ВременнаяТаблицаДокумента
    |	ИЗ
	|		РегистрНакопления.ПотребностиЗаказовНаПроизводство.Остатки(&ДатаКон, ЗаказНаПроизводство = &Заказ) КАК РегПотребности 
	|";
	ЗапросПотребности.УстановитьПараметр( "Заказ", Заказ);
	Если КонДата = '00010101000000' Тогда
		ЗапросПотребности.УстановитьПараметр( "ДатаКон", КонДата);
	Иначе
		ЗапросПотребности.УстановитьПараметр( "ДатаКон", Новый Граница( КонецДня(КонДата), ВидГраницы.Включая));
	КонецЕсли;
	
	ЗапросПотребности.Выполнить();
	
	ТекстЗапроса = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	РегЗаказы.Материал КАК Материал,
	|	РегЗаказы.ХарактеристикаМатериала КАК ХарактеристикаМатериала,
	|	РегЗаказы.Материал.ЕдиницаХраненияОстатков КАК ЕдИзм,
	|	ПРЕДСТАВЛЕНИЕ(РегЗаказы.Материал) КАК ПечМатериал,
	|	ПРЕДСТАВЛЕНИЕ(РегЗаказы.ХарактеристикаМатериала) КАК ПечХарактеристикаМатериала,
	|	СУММА(РегЗаказы.КолПотребность) КАК КолПотребность,
	|	СУММА(РегЗаказы.КолРезерв) КАК КолРезерв,
	|	СУММА(РегЗаказы.КолРазмещено) КАК КолРазмещено,
	|	СУММА(РегЗаказы.КолНЗП) КАК КолНЗП,
	|	СУММА(РегЗаказы.КолПотребность - РегЗаказы.КолРезерв - РегЗаказы.КолРазмещено - РегЗаказы.КолНЗП) КАК Необеспечено,
	|	МИНИМУМ(ЕстьNULL(ТоварыНаСкладах.КоличествоОстаток,0)
	|			+ЕстьNULL(ТоварыВРознице.КоличествоОстаток,0)
	|			-ЕстьNULL(ТоварыВРезервеНаСкладах.КоличествоОстаток,0)
	|			-ЕстьNULL(ТоварыКПередачеСоСкладов.КоличествоОстаток,0)) КАК СвободныйОстаток
	|ИЗ
	|	(ВЫБРАТЬ
	|		РегПотребности.Материал,
	|		РегПотребности.ХарактеристикаМатериала,
	|		РегПотребности.КолПотребность,
	|		0 КАК КолРезерв,
	|		0 КАК КолРазмещено,
	|		0 КАК КолНЗП
	|	ИЗ
	|		ВременнаяТаблицаДокумента КАК РегПотребности
	|	
	//Резерв складывается из трех регистров: ТоварыВРезервеНаСкладах
	//	ТоварыКПередачеСоСкладов, ТоварыКПолучениюНаСклады (с отрицательным знаком) - для учета резервов, перемещаемых по ордерной схеме
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		РегРезерв.Номенклатура,
	|		РегРезерв.ХарактеристикаНоменклатуры,
	|		0,
	|		РегРезерв.КоличествоОстаток,
	|		0,
	|		0
	|	ИЗ
	|		РегистрНакопления.ТоварыВРезервеНаСкладах.Остатки(&ДатаКон, ДокументРезерва = &Заказ И 
	|				((Номенклатура,ХарактеристикаНоменклатуры) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента)) ) КАК РегРезерв
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		РегРезервКПередаче.Номенклатура,
	|		РегРезервКПередаче.ХарактеристикаНоменклатуры,
	|		0,
	|		РегРезервКПередаче.КоличествоОстаток,
	|		0,
	|		0
	|	ИЗ
	|		РегистрНакопления.ТоварыКПередачеСоСкладов.Остатки(&ДатаКон, ДокументРезерва = &Заказ И 
	|				((Номенклатура,ХарактеристикаНоменклатуры) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента)) ) КАК РегРезервКПередаче
	|
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		РегРезервКПолучению.Номенклатура,
	|		РегРезервКПолучению.ХарактеристикаНоменклатуры,
	|		0,
	|		(-1) * РегРезервКПолучению.КоличествоОстаток,
	|		0,
	|		0
	|	ИЗ
	|		РегистрНакопления.ТоварыКПолучениюНаСклады.Остатки(&ДатаКон, ДокументРезерва = &Заказ И 
	|				((Номенклатура,ХарактеристикаНоменклатуры) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента)) ) КАК РегРезервКПолучению
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		РегРазмещение.Номенклатура,
	|		РегРазмещение.ХарактеристикаНоменклатуры,
	|		0,
	|		0,
	|		РегРазмещение.КоличествоОстаток,
	|		0
	|	ИЗ
	|		РегистрНакопления.РазмещениеЗаказовПокупателей.Остатки(&ДатаКон, ЗаказПокупателя = &Заказ И
	|			((Номенклатура,ХарактеристикаНоменклатуры) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента))) КАК РегРазмещение
	|//Подзапрос_НЗП	
	|	) КАК РегЗаказы
	|	ЛЕВОЕ СОЕДИНЕНИЕ
	|		РегистрНакопления.ТоварыНаСкладах.Остатки(&ДатаКон, ((Номенклатура,ХарактеристикаНоменклатуры) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента))) КАК ТоварыНаСкладах
	|	ПО ТоварыНаСкладах.Номенклатура = РегЗаказы.Материал И
	|		ТоварыНаСкладах.ХарактеристикаНоменклатуры = РегЗаказы.ХарактеристикаМатериала
	|	ЛЕВОЕ СОЕДИНЕНИЕ
	|		РегистрНакопления.ТоварыВРознице.Остатки(&ДатаКон, ((Номенклатура,ХарактеристикаНоменклатуры) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента))) КАК ТоварыВРознице
	|	ПО ТоварыВРознице.Номенклатура = РегЗаказы.Материал И
	|		ТоварыВРознице.ХарактеристикаНоменклатуры = РегЗаказы.ХарактеристикаМатериала
	|	ЛЕВОЕ СОЕДИНЕНИЕ
	|		РегистрНакопления.ТоварыВРезервеНаСкладах.Остатки(&ДатаКон, ((Номенклатура,ХарактеристикаНоменклатуры) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента))) КАК ТоварыВРезервеНаСкладах
	|	ПО ТоварыВРезервеНаСкладах.Номенклатура = РегЗаказы.Материал И
	|		ТоварыВРезервеНаСкладах.ХарактеристикаНоменклатуры = РегЗаказы.ХарактеристикаМатериала
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыКПередачеСоСкладов.Остатки(&ДатаКон, ((Номенклатура,ХарактеристикаНоменклатуры) В (ВЫБРАТЬ Материал,ХарактеристикаМатериала ИЗ ВременнаяТаблицаДокумента))) КАК ТоварыКПередачеСоСкладов
	|	ПО ТоварыКПередачеСоСкладов.Номенклатура = РегЗаказы.Материал И
	|		ТоварыКПередачеСоСкладов.ХарактеристикаНоменклатуры = РегЗаказы.ХарактеристикаМатериала
	|	ЛЕВОЕ СОЕДИНЕНИЕ ВременнаяТаблицаДокумента КАК РегПотребностиЕдиницы
	|	ПО РегПотребностиЕдиницы.Материал = РегЗаказы.Материал И
	|		РегПотребностиЕдиницы.ХарактеристикаМатериала = РегЗаказы.ХарактеристикаМатериала
	|
	|СГРУППИРОВАТЬ ПО
	|	РегЗаказы.Материал,
	|	РегЗаказы.ХарактеристикаМатериала,
	|	ЕстьNULL(РегПотребностиЕдиницы.ЕдИзм,РегЗаказы.Материал.ЕдиницаХраненияОстатков)
	|
	|УПОРЯДОЧИТЬ ПО
	|	РегЗаказы.Материал.Наименование, РегЗаказы.ХарактеристикаМатериала.Наименование,
	|	ЕстьNULL(РегПотребностиЕдиницы.ЕдИзм,РегЗаказы.Материал.ЕдиницаХраненияОстатков)";
	флРасширеннаяАналитика = ложь;
	Если ВидимостьНЗП Тогда
		Если глЗначениеПеременной("ИспользоватьРасширеннуюАналитикуУчетаНоменклатурыИЗатрат") И
			глЗначениеПеременной("ДатаНачалаИспользованияРасширеннойАналитикиУчетаНоменклатурыИЗатрат") <= КонДата Тогда
			РежимИспользованияРасширеннойАналитики = глЗначениеПеременной("РежимИспользованияРасширеннойАналитикиУчетаНоменклатурыИЗатрат");
			
			Если РежимИспользованияРасширеннойАналитики = Перечисления.РежимыИспользованияРасширеннойАналитики.УправленческийИРегламентированныйУчет Тогда
				ВидОтраженияВУчете = Перечисления.ВидыОтраженияВУчете.ОтражатьВУправленческомУчете;
			Иначе
				ВидОтраженияВУчете = Перечисления.ВидыОтраженияВУчете.ОтражатьВРегламентированномУчете;
			КонецЕсли;

			ТекстЗапросаНЗП = СформироватьТекстЗапросаНЗП_РасширеннаяАналитика(ВидОтраженияВУчете);
			флРасширеннаяАналитика = истина;

		Иначе
			ТекстЗапросаНЗП = СформироватьТекстЗапросаНЗП();
		КонецЕсли;
		ТекстЗапроса = стрЗаменить(ТекстЗапроса,"//Подзапрос_НЗП","
		|ОБЪЕДИНИТЬ ВСЕ 
		|"+ТекстЗапросаНЗП);
	КонецЕсли;
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;

	Запрос.УстановитьПараметр( "Заказ", Заказ);
	Если КонДата = '00010101000000' Тогда
		Запрос.УстановитьПараметр( "ДатаКон", КонДата);
	Иначе
		Запрос.УстановитьПараметр( "ДатаКон", Новый Граница( КонецДня(КонДата), ВидГраницы.Включая));
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	// Формирование печатной формы
	Макет = ПолучитьМакет("АнализЗаказа");
	
	Область = Макет.ПолучитьОбласть("ШапкаМатериалы"+?(ВидимостьНЗП, "","БезНЗП"));
	ТабДокумент.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("СтрокаМатериалы"+?(ВидимостьНЗП, "","БезНЗП"));
	
	Обход = РезультатЗапроса.Выбрать();
	Пока Обход.Следующий() Цикл
		РасшифровкаРезерв      = Новый Структура("ВидОтчета", "ТоварыВРезервеНаСкладах");
		РасшифровкаРазмещено   = Новый Структура("ВидОтчета", "РазмещенияВЗаказах");
		Если флРасширеннаяАналитика Тогда
			РасшифровкаНЗП         = Новый Структура("ВидОтчета,ВидОтраженияВУчете,ОтчетНаСистемеКомпоновки", "ВедомостьПоУчетуЗатрат",ВидОтраженияВУчете,истина);
		Иначе	
			РасшифровкаНЗП         = Новый Структура("ВидОтчета", "ВедомостьПроизводственныеЗатраты");
		КонецЕсли;
		
		РасшифровкаСвободныйОстаток = Новый Структура("ВидОтчета", "АнализДоступностиТоваровНаСкладах");

		Область.Параметры.ПечМатериал  = Обход.ПечМатериал+?(ЗначениеЗаполнено(Обход.ПечХарактеристикаМатериала)," ("+Обход.ПечХарактеристикаМатериала+")","");
		Область.Параметры.Материал     = Обход.Материал;
		Область.Параметры.ПечЕдИзм     = СокрЛП(Обход.ЕдИзм);
		Область.Параметры.ЕдИзм        = Обход.ЕдИзм;
		
		Область.Параметры.КолРезерв      = Обход.КолРезерв;
		Область.Параметры.КолРазмещено   = Обход.КолРазмещено;
		Область.Параметры.СвободныйОстаток   = Обход.СвободныйОстаток;
		Если ВидимостьНЗП Тогда
			Область.Параметры.КолНЗП         = Обход.КолНЗП;			
			РасшифровкаНЗП      .Вставить("Номенклатура", Обход.Материал);
			РасшифровкаНЗП      .Вставить("ХарактеристикаНоменклатуры", Обход.ХарактеристикаМатериала);

			Область.Параметры.РасшифровкаНЗП         = РасшифровкаНЗП;
		КонецЕсли;
		
		Область.Параметры.КолПотребность = Обход.КолПотребность;
		Область.Параметры.Необеспечено   = Обход.Необеспечено;
		
		РасшифровкаРезерв   .Вставить("Номенклатура", Обход.Материал);
		РасшифровкаРазмещено.Вставить("Номенклатура", Обход.Материал);
		РасшифровкаСвободныйОстаток.Вставить("Номенклатура", Обход.Материал);
        РасшифровкаРезерв   .Вставить("ХарактеристикаНоменклатуры", Обход.ХарактеристикаМатериала);
		РасшифровкаРазмещено.Вставить("ХарактеристикаНоменклатуры", Обход.ХарактеристикаМатериала);
		РасшифровкаСвободныйОстаток.Вставить("ХарактеристикаНоменклатуры", Обход.ХарактеристикаМатериала);

	
		Область.Параметры.РасшифровкаРезерв      = РасшифровкаРезерв;
		Область.Параметры.РасшифровкаРазмещено   = РасшифровкаРазмещено;
		Область.Параметры.РасшифровкаСвободныйОстаток   = РасшифровкаСвободныйОстаток;		
		ТабДокумент.Вывести(Область);
	
	КонецЦикла;
	
	Область = Макет.ПолучитьОбласть("ТабМатериалыНиз"+?(ВидимостьНЗП, "","БезНЗП"));
	ТабДокумент.Вывести(Область);

	ОбластьВыполнениеЗаказа = ТабДокумент.Область(3,2,3,2);
	ОбластьВыполнениеЗаказа.Текст = ?(флЗаказВыполнен,"Заказ выполнен","Заказ не выполнен");

КонецПроцедуры // ОбновитьОтчет()

#КОНЕЦЕСЛИ