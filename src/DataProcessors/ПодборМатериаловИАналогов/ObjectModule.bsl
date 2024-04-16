// Процедура рекурсивно загружает дерево материалов в таб. остатков
//
Процедура ЗагрузитьДеревоВОстатки( Дерево, ТабОстатки, ПропуститьУровень)
	
	Для Каждого СтрокаДерева Из Дерево.Строки Цикл
		Если ПропуститьУровень Тогда // Первый уровень - продукция
			ЗагрузитьДеревоВОстатки( СтрокаДерева, ТабОстатки, Ложь);
		Иначе
			НоваяСтрока = ТабОстатки.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаДерева);
			Если ТипЗнч(НоваяСтрока.Номенклатура) = Тип("СправочникСсылка.Номенклатура") Тогда
				НоваяСтрока.КоэфХранения = НоваяСтрока.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент;
			КонецЕсли;
			Если НоваяСтрока.КоэфХранения = 0 Тогда
				НоваяСтрока.КоэфХранения = 1;	
			КонецЕсли;
			Если СтрокаДерева.Строки.Количество() > 0 Тогда
				ЗагрузитьДеревоВОстатки( СтрокаДерева, ТабОстатки, Ложь);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры // ЗагрузитьДеревоВОстатки()

// Процедура заполняет количество материала на выпуск по данным остатков материалов.
//
Процедура РассчитатьКоличествоМатериала(СтрокаМатериала, КоличествоНорматив)
	
	СтруктураПоиска = Новый Структура("Номенклатура, ХарактеристикаНоменклатуры");
	ЗаполнитьЗначенияСвойств(СтруктураПоиска, СтрокаМатериала);
	
	МассивСтрок = ОстаткиМатериалов.НайтиСтроки(СтруктураПоиска);
	Если МассивСтрок.Количество() > 0 Тогда
					
		СтрокаОстатка = МассивСтрок[0];
		ОстатокМатериала = ?(СтрокаМатериала.Коэффициент <> 0, (СтрокаОстатка.Остаток - СтрокаОстатка.Распределено) * СтрокаОстатка.Коэффициент / СтрокаМатериала.Коэффициент, 0);
		Если ОстатокМатериала > 0 Тогда
			
			СтрокаМатериала.КоличествоВыпуск = Мин(ОстатокМатериала, КоличествоНорматив);
			СтрокаМатериала.КоличествоВсего = СтрокаМатериала.КоличествоВыпуск;
			
			СтрокаОстатка.Распределено = СтрокаОстатка.Распределено + ?(СтрокаОстатка.Коэффициент <> 0, СтрокаМатериала.КоличествоВыпуск * СтрокаМатериала.Коэффициент / СтрокаОстатка.Коэффициент, 0);
			
		Иначе
			
			СтрокаМатериала.КоличествоВыпуск = 0;
			СтрокаМатериала.КоличествоВсего  = 0;
			
		КонецЕсли;
		
	Иначе
		
		СтрокаМатериала.КоличествоВыпуск = 0;
		СтрокаМатериала.КоличествоВсего  = 0;
		
	КонецЕсли;
	
КонецПроцедуры // РассчитатьКоличествоМатериала()

// Процедура производит автоматическую замену на аналоги номенклатуры.
//
Процедура АвтозаменаНаАналоги(ДеревоИсходныеКомплектующие) Экспорт
	
	ТаблицаЗначений = ОстаткиМатериалов.Выгрузить();
	ТаблицаЗначений.ЗаполнитьЗначения(0, "Распределено");
	ОстаткиМатериалов.Загрузить(ТаблицаЗначений);
	
	// Первый проход - используем имеющиеся материалы только как основные комплектующие
	Для Каждого СтрокаПродукции Из ДеревоИсходныеКомплектующие.Строки Цикл
		
		Для Каждого СтрокаМатериала Из СтрокаПродукции.Строки Цикл
			
			Если СтрокаМатериала.Используется Тогда
				РассчитатьКоличествоМатериала(СтрокаМатериала, СтрокаМатериала.Количество);
			Иначе
				СтрокаМатериала.КоличествоВыпуск = 0;
				СтрокаМатериала.КоличествоВсего  = 0;
			КонецЕсли;
			
			Для Каждого СтрокаАналога Из СтрокаМатериала.Строки Цикл
				
				КоэффициентЗамены = ?(СтрокаМатериала.Количество <> 0, СтрокаАналога.Количество / СтрокаМатериала.Количество, 0);
				КоличествоДляЗамены = (СтрокаМатериала.Количество - СтрокаМатериала.КоличествоВсего) * КоэффициентЗамены;
				
				// Замена на другую номенклатуру.
				Если ТипЗнч(СтрокаАналога.Номенклатура) = Тип("СправочникСсылка.Номенклатура") Тогда
				
					Если СтрокаМатериала.Используется
					   И КоличествоДляЗамены > 0
					Тогда
						РассчитатьКоличествоМатериала(СтрокаАналога, КоличествоДляЗамены);
						СтрокаАналога.КоличествоВсего = 0;
					Иначе
						СтрокаАналога.КоличествоВыпуск = 0;
						СтрокаАналога.КоличествоВсего = 0;
					КонецЕсли;
					
					Если КоэффициентЗамены <> 0 Тогда
						СтрокаМатериала.КоличествоВсего = СтрокаМатериала.КоличествоВсего + СтрокаАналога.КоличествоВыпуск / КоэффициентЗамены;
					КонецЕсли;
					
				// Замена на узел.	
				ИначеЕсли ТипЗнч(СтрокаАналога.Номенклатура) = Тип("СправочникСсылка.НоменклатурныеУзлы") Тогда
				
					Для Каждого СтрокаУзла Из СтрокаМатериала.Строки Цикл
						
						КоэффициентЗамены = ?(СтрокаМатериала.Количество <> 0, СтрокаАналога.Количество / СтрокаМатериала.Количество, 0);
						КоличествоДляЗамены = (СтрокаМатериала.Количество - СтрокаМатериала.КоличествоВсего) * КоэффициентЗамены;
						
						// Рассчитаем максимальное количество узлов для возможной замены.
						Для Каждого СтрокаКомплектующей Из СтрокаУзла.Строки Цикл
							
							Если СтрокаМатериала.Используется
							   И КоличествоДляЗамены > 0
							Тогда
							
								КоэффициентКомплектующей = ?(СтрокаУзла.Количество <> 0, СтрокаКомплектующей.Количество / СтрокаУзла.Количество, 0);
							
								СтруктураПоиска = Новый Структура("Номенклатура, ХарактеристикаНоменклатуры");
								ЗаполнитьЗначенияСвойств(СтруктураПоиска, СтрокаКомплектующей);
								
								МассивСтрок = ОстаткиМатериалов.НайтиСтроки(СтруктураПоиска);
								Если МассивСтрок.Количество() > 0 Тогда
												
									СтрокаОстатка = МассивСтрок[0];
									ОстатокМатериала = СтрокаОстатка.Остаток - СтрокаОстатка.Распределено;
									КоличествоУзлов = ?(КоэффициентКомплектующей <> 0, ОстатокМатериала / КоэффициентКомплектующей, 0);
									
									Если КоличествоУзлов < КоличествоДляЗамены Тогда
										КоличествоДляЗамены = Цел(КоличествоУзлов);
									КонецЕсли;
									
								КонецЕсли;

							КонецЕсли;
							
						КонецЦикла;
						
						Для Каждого СтрокаКомплектующей Из СтрокаУзла.Строки Цикл
							
							Если СтрокаМатериала.Используется
							   И КоличествоДляЗамены > 0
							Тогда
								КоэффициентКомплектующей = ?(СтрокаУзла.Количество <> 0, СтрокаКомплектующей.Количество / СтрокаУзла.Количество, 0);
								КоличествоУзлов = КоличествоДляЗамены * КоэффициентКомплектующей;
								РассчитатьКоличествоМатериала(СтрокаКомплектующей, КоличествоУзлов);
								СтрокаКомплектующей.КоличествоВсего  = 0;
							Иначе
								СтрокаКомплектующей.КоличествоВыпуск = 0;
								СтрокаКомплектующей.КоличествоВсего  = 0;
							КонецЕсли;
							
						КонецЦикла;
						
						Если КоэффициентЗамены <> 0 Тогда
							СтрокаМатериала.КоличествоВсего = СтрокаМатериала.КоличествоВсего + КоличествоДляЗамены / КоэффициентЗамены;
						КонецЕсли;
						
					КонецЦикла; // СтрокаУзла
				
				КонецЕсли;
				
			КонецЦикла; // СтрокаАналога
			
		КонецЦикла; // СтрокаМатериала
		
	КонецЦикла;
		
КонецПроцедуры // АвтозаменаНаАналоги()
