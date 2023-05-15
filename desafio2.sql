-- Relatório Dados de Cargo Primeiro/Atual
-- Id do funcionário,
--Nome do Funcionário,
--Data Efetiva,
--Cargo Atual,
--Primeiro Cargo,
--Salário Atual,
--Primeiro Salário,
--Valor com a Diferença do Primeiro e ultimo salário,
--% do Primeiro para Ultimo Salário

SELECT
    PPNF.PERSON_ID                                                                   AS "Id do funcionário",
    PPNF.DISPLAY_NAME                                                                AS "Nome do funcionário",
    TO_CHAR(PPOS.DATE_START,
    'DD/MM/YYYY')                                                                    AS "Data Efetiva",
    PJOB.NAME                                                                        AS "Cargo Atual",
    FIRST_JOB.NAME                                                                   AS "Primeiro Cargo",
    CSAL.SALARY_AMOUNT                                                               AS "Salário",
    FIRST_CSAL.SALARY_AMOUNT                                                         AS "Primeiro Salário",
    (CSAL.SALARY_AMOUNT - FIRST_CSAL.SALARY_AMOUNT)                                  AS "Diferença",
    (CSAL.SALARY_AMOUNT - FIRST_CSAL.SALARY_AMOUNT) / FIRST_CSAL.SALARY_AMOUNT * 100 AS "Percentual de Diferença"
FROM
    PER_PERSON_NAMES_F     PPNF,
    PER_PERIODS_OF_SERVICE PPOS,
    PER_ALL_ASSIGNMENTS_M  PAAM,
    PER_JOBS               PJOB,
    PER_ALL_ASSIGNMENTS_M  FIRST_PAAM,
    PER_JOBS               FIRST_JOB,
    CMP_SALARY             CSAL,
    CMP_SALARY             FIRST_CSAL
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
 --FIRST_PAAM
    AND PAAM.PERSON_ID = PPNF.PERSON_ID
    AND PAAM.ASSIGNMENT_TYPE = 'E'
    AND PAAM.EFFECTIVE_START_DATE= (
        SELECT
            MIN(EFFECTIVE_START_DATE)
        FROM
            PER_ALL_ASSIGNMENTS_M PAAM_INNER
        WHERE
            PAAM_INNER.PERSON_ID = PPNF.PERSON_ID
            AND PAAM_INNER.WORK_TERMS_ASSIGNMENT_ID IS NOT NULL
            AND PAAM_INNER.ASSIGNMENT_TYPE = PAAM.ASSIGNMENT_TYPE
            AND PAAM_INNER.ASSIGNMENT_STATUS_TYPE = PAAM.ASSIGNMENT_STATUS_TYPE
            AND PAAM_INNER.PRIMARY_FLAG = PAAM.PRIMARY_FLAG
    )
 --FIRST_JOB
    AND FIRST_JOB.JOB_ID = FIRST_PAAM.JOB_ID
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
 --FIRST CSAL
    AND FIRST_CSAL.DATE_TO = (
        SELECT
            MIN(DATE_TO)
        FROM
            CMP_SALARY FIRST_CSAL
        WHERE
            FIRST_CSAL.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
            AND FIRST_CSAL.PERSON_ID = FIRST_CSAL.PERSON_ID
    )
    AND FIRST_CSAL.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
    AND FIRST_CSAL.PERSON_ID = PAAM.PERSON_ID
    AND FIRST_CSAL.SALARY_APPROVED = 'Y'