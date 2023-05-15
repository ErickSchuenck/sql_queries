--Relatório Dados de Cargo Anterior/Atual,
-- Id do funcionário,
-- Nome do Funcionário,
-- Data Efetiva,
-- Cargo Atual,
-- Cargo Anterior,
-- Salário Atual,
-- Salário Anterior,
-- % de Reajuste entre Salário atual e Anterior

SELECT
    PPNF.PERSON_ID AS "Id do funcionário",
    PPNF.DISPLAY_NAME AS "Nome do funcionário",
    TO_CHAR(PPOS.DATE_START,
    'DD/MM/YYYY') AS "Data Efetiva",
    PJOB.NAME AS "Cargo Atual",
    PREV_JOB.NAME AS "Cargo Anterior",
    CSAL.SALARY_AMOUNT AS "Salário",
    PREV_CSAL.SALARY_AMOUNT AS "Salário Anterior",
    (CSAL.SALARY_AMOUNT - PREV_CSAL.SALARY_AMOUNT) / PREV_CSAL.SALARY_AMOUNT * 100 AS "Percentual de Diferença"
FROM
    PER_PERSON_NAMES_F PPNF,
    PER_PERIODS_OF_SERVICE PPOS,
    PER_ALL_ASSIGNMENTS_M PAAM,
    PER_JOBS PJOB,
    PER_ALL_ASSIGNMENTS_M PREV_PAAM,
    PER_JOBS PREV_JOB,
    CMP_SALARY CSAL,
    CMP_SALARY PREV_CSAL
WHERE
 --PASSAR ID DO FUNCIONÁRIO PARA A QUERY
    PPNF.PERSON_ID = NVL(:P_PERSON_ID,
    PPNF.PERSON_ID)
 --PPNF
    AND PPNF.NAME_TYPE = 'GLOBAL'
 --PPOS
    AND PPOS.PERSON_ID = PPNF.PERSON_ID
 --PAAM (USING JOB_ID LINKS PJOB ---PAAM--> PPNF)
    AND PAAM.PERSON_ID = PPNF.PERSON_ID
    AND PAAM.ASSIGNMENT_TYPE = 'E'
    AND PAAM.EFFECTIVE_START_DATE= (
        SELECT
            MAX(EFFECTIVE_START_DATE)
        FROM
            PER_ALL_ASSIGNMENTS_M PAAM_INNER
        WHERE
            PAAM_INNER.PERSON_ID = PPNF.PERSON_ID
            AND PAAM_INNER.WORK_TERMS_ASSIGNMENT_ID IS NOT NULL
            AND PAAM_INNER.ASSIGNMENT_TYPE = PAAM.ASSIGNMENT_TYPE
            AND PAAM_INNER.ASSIGNMENT_STATUS_TYPE = PAAM.ASSIGNMENT_STATUS_TYPE
            AND PAAM_INNER.PRIMARY_FLAG = PAAM.PRIMARY_FLAG
    )
 --PJOB
    AND PJOB.JOB_ID = PAAM.JOB_ID
 --PREV_PAAM
    AND PREV_PAAM.PERSON_ID = PPNF.PERSON_ID
    AND PREV_PAAM.ASSIGNMENT_TYPE = 'E'
 --PREV_JOB
    AND PREV_JOB.JOB_ID = PREV_PAAM.JOB_ID
 -- CSAL
    AND CSAL.DATE_TO = (
        SELECT
            MAX(DATE_TO)
        FROM
            CMP_SALARY CSAL_INNER
        WHERE
            CSAL_INNER.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
            AND CSAL_INNER.PERSON_ID = CSAL.PERSON_ID
    )
    AND CSAL.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
    AND CSAL.PERSON_ID = PAAM.PERSON_ID
    AND CSAL.SALARY_APPROVED = 'Y'
 --PREV CSAL
    AND PREV_CSAL.DATE_TO = (
        SELECT
            MAX(DATE_TO)
        FROM
            CMP_SALARY PREV_CSAL_INNER
        WHERE
            PREV_CSAL_INNER.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
            AND PREV_CSAL_INNER.PERSON_ID = PREV_CSAL.PERSON_ID
    )
    AND PREV_CSAL.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
    AND PREV_CSAL.PERSON_ID = PAAM.PERSON_ID
    AND PREV_CSAL.SALARY_APPROVED = 'Y'
 ------------------------------
 ------------------------------
 ------------------------------
 ------------------------------
 ------------------------------
 ------------------------------
 ------------------------------
    SELECT
        PPNF.PERSON_ID AS "Id do funcionário",
        CSAL.SALARY_AMOUNT AS "SALARIO",
        PREV_CSAL.SALARY_AMOUNT AS "ANTERIOR"
    FROM
        PER_PERSON_NAMES_F PPNF,
        CMP_SALARY CSAL,
        CMP_SALARY PREV_CSAL,
        PER_ALL_ASSIGNMENTS_M PAAM
    WHERE
        PPNF.PERSON_ID = NVL(:P_PERSON_ID,
        PPNF.PERSON_ID)
        AND PPNF.NAME_TYPE = 'GLOBAL'
 -- CSAL
        AND CSAL.DATE_TO = (
            SELECT
                MAX(DATE_TO)
            FROM
                CMP_SALARY CSAL_INNER
            WHERE
                CSAL_INNER.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
                AND CSAL_INNER.PERSON_ID = CSAL.PERSON_ID
        )
        AND CSAL.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
        AND CSAL.PERSON_ID = PAAM.PERSON_ID
        AND CSAL.SALARY_APPROVED = 'Y'
 -- PREV_CSAL
        AND PREV_CSAL.DATE_TO = (
            SELECT
                MAX(DATE_TO)
            FROM
                CMP_SALARY PREV_CSAL_INNER
            WHERE
                PREV_CSAL_INNER.DATE_TO NOT IN (
                    SELECT
                        MAX(DATE_TO)
                    FROM
                        CMP_SALARY
                )
                AND PREV_CSAL_INNER.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
                AND PREV_CSAL_INNER.PERSON_ID = PREV_CSAL.PERSON_ID
        )
        AND PREV_CSAL.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
        AND PREV_CSAL.PERSON_ID = PAAM.PERSON_ID
        AND PREV_CSAL.SALARY_APPROVED = 'Y'