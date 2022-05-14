--SELECT * FROM dbo.CovidDeaths
--ORDER BY 3,4

--SELECT * FROM dbo.CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location = 'Vietnam'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Percent_Population_Infected
FROM CovidDeaths
--WHERE location = 'United States'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 
AS Percent_Population_Infected
FROM CovidDeaths
--WHERE location = 'United States'
GROUP BY Location, population
ORDER BY Percent_Population_Infected DESC

-- Showing Countries with Highest Death Count per population
SELECT Location, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY Total_Death_Count DESC

-- Let's break things down by continent
SELECT continent, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- Showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- Global numbers
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths,
SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location ORDER BY CD.location, CD.date) AS Rolling_People_Vaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated) AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location ORDER BY CD.location, CD.date) AS Rolling_People_Vaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)
SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacciantions numeric,
Rolling_People_Vaccinated numeric
)
INSERT INTO #Percent_Population_Vaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location ORDER BY CD.location, CD.date) AS Rolling_People_Vaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM #Percent_Population_Vaccinated

-- Create View to store data for later visualizations
CREATE VIEW Percent_Population_Vaccinated AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location ORDER BY CD.location, CD.date) AS Rolling_People_Vaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

SELECT * FROM Percent_Population_Vaccinated
