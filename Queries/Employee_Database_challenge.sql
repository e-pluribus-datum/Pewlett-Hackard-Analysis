-- Create new table joined from employees and titles
-- Birth dates are between a date range
SELECT em.emp_no, em.first_name, em.last_name,
	ti.title, ti.from_date, ti.to_date
INTO retirement_titles
FROM employees as em
	INNER JOIN titles as ti
	ON em.emp_no = ti.emp_no
WHERE (em.birth_date BETWEEN '1952-01-01' and '1955-12-31')
ORDER BY emp_no

-- Remove duplicate rows, inactive employees
SELECT DISTINCT ON (re.emp_no) emp_no, first_name, last_name, title
INTO unique_titles
FROM retirement_titles as re
WHERE to_date = '9999-01-01'
ORDER BY emp_no ASC, to_date DESC

-- Get counts of titles retiring
SELECT COUNT(ut.title), title
INTO retiring_titles
FROM unique_titles as ut
GROUP BY title
ORDER BY count DESC

-- Mentorship eligibility
SELECT
	em.emp_no, em.first_name, em.last_name, em.birth_date,
	de.from_date, de.to_date,
	ti.title
-- INTO mentorship_eligibility
FROM employees as em
	INNER JOIN dept_emp	as de
	ON em.emp_no = de.emp_no
	INNER JOIN 	-- first filter titles to yield the most recent title for each employee
				-- simply 'INNER JOIN titles as ti' gives inconsistent results!
			(SELECT DISTINCT ON(emp_no) emp_no, title, max(from_date), max(to_date)
			FROM titles as ti
			GROUP BY emp_no, title
			ORDER BY emp_no ASC, max(to_date) DESC, max(from_date) DESC)
	as ti
	ON em.emp_no = ti.emp_no
WHERE de.to_date = '9999-01-01' 	-- active employees
	AND (em.birth_date BETWEEN '1965-01-01' and '1965-12-31')
ORDER BY em.emp_no ASC