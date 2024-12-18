## 1 Общее описание
Настоящий проект является одним из исследовательских проектов, посвященных построениею аппаратного межсетевого экрана (файерволла) на базе проекта `hXDP`
Разработка межсетевого экрана это серия научно-исследовательских и прикладных проектов-репозитоиев в рамках проекта [Wissance](https://github.com/orgs/Wissance/projects/8)

### 1.1 Осноные функции межсетевого экрана

### 1.2 Оборудование (платы + инструменты)

Данное решение будет построено на базе `FPGA Kintex-7` и платы [Kintex-7 Base C](https://aliexpress.ru/item/1005005361609787.html?sku_id=12000032740832285&spm=a2g2w.productlist.search_results.0.cded215dOq44Gp)

## 2 SDK и софт необходимы для работы

В процессе выполнения задач данный раздел будет пополняться
1. [Архив с документацией на плату и инструменты разработки](https://onedrive.live.com/?authkey=%21AMGwyB%5FC%2Dl98Vuo&id=B2CDC3A30980D5BD%21189851&cid=B2CDC3A30980D5BD) , в состав архива входит **Vivado 18.3**
2. ???

## 3 Задачи проекта

### Этап 1 (~ до середины декабря 2024 г.)

1. Проверка работоспособности проекта `hXDP` (компиляция и прошивка битстрима) решения `hXDP` на платах отличных от `SUME`
  * [ ] разобраться и описать принцип работы данного проекта (аппартного ускорения обработки пакетов)
  * [x] портирование / создание `Vivado` проекта на плату `Kintex-7 Base C`
  * [ ] прошивка платы и запуск `hXDP` на этой плате (определение какой софт крутится на процессорных ядрах и как конфигурируется)
2. Проверка возможности обработки пакетов на скорости `1Гбит/с` (пропуск, фильтрация пакетов)
  * [ ] разработка методик тестирования функций;
  * [ ] проведение тестирования;
  * [ ] создание тестбенчей (если нужно).

## 4 Полезные ресусры

1. [Статья про обработку пакетов с использованием `hXDP`](https://dl.acm.org/doi/pdf/10.1145/3543668) **находится в репо** в `docs`
2. [Репозиторий по материалам статьи](https://github.com/axbryd/hXDP-Artifacts)
3. [Архив с Vivado-проектом](https://zenodo.org/records/4015082#.X1I-FgczadY) **находится в репо** в `resources`

## 5 Авторы / контрибьюторы

<a href="https://github.com/Wissance/FpgaNetHXDP/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Wissance/FpgaNetHXDP" />
</a>
