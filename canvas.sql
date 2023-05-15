SELECT
    PPNF.DISPLAY_NAME,
    PAPF.PERSON_NUMBER,
    PAAM.ASSIGNMENT_NUMBER,
    PPOS.DATE_START,
    PJOB.NAME
FROM
    PER_ALL_PEOPLE_F       PAPF,
    PER_PERSON_NAMES_F     PPNF,
    PER_ALL_ASSIGNMENTS_M  PAAM,
    PER_PERIODS_OF_SERVICE PPOS,
    PER_JOBS               PJOB
WHERE
 --papf
    PAPF.PERSON_NUMBER = NVL(:P_PERSON_NUMBER,
    PAPF.PERSON_NUMBER)
    AND PAPF.PERSON_ID = PPNF.PERSON_ID
    AND PAPF.EFFECTIVE_START_DATE = (
        SELECT
            MAX(PAPF_INNER.EFFECTIVE_START_DATE)
        FROM
            PER_ALL_PEOPLE_F PAPF_INNER
        WHERE
            PAPF_INNER.PERSON_NUMBER = PAPF.PERSON_NUMBER
    )
 --ppnf
    AND PPNF.NAME_TYPE = 'GLOBAL'
    AND PPNF.EFFECTIVE_START_DATE = (
        SELECT
            MAX(EFFECTIVE_START_DATE)
        FROM
            PER_PERSON_NAMES_F
        WHERE
            PERSON_ID = PPNF.PERSON_ID
            AND NAME_TYPE = PPNF.NAME_TYPE
    )
 --paam
    AND PAAM.PERSON_ID = PPNF.PERSON_ID
    AND PAAM.ASSIGNMENT_TYPE = 'E'
    AND PAAM.EFFECTIVE_START_DATE= (
        SELECT
            MAX(EFFECTIVE_START_DATE)
        FROM
            PER_ALL_ASSIGNMENTS_M PAAM_INNER
        WHERE
            PAAM_INNER.PERSON_ID = PAPF.PERSON_ID
            AND PAAM_INNER.WORK_TERMS_ASSIGNMENT_ID IS NOT NULL
            AND PAAM_INNER.ASSIGNMENT_TYPE = PAAM.ASSIGNMENT_TYPE
            AND PAAM_INNER.ASSIGNMENT_STATUS_TYPE = PAAM.ASSIGNMENT_STATUS_TYPE
            AND PAAM_INNER.PRIMARY_FLAG = PAAM.PRIMARY_FLAG
    )
 --ppos
    AND PPOS.PERSON_ID = PPNF.PERSON_ID
    AND PPOS.PERIOD_OF_SERVICE_ID = PAAM.PERIOD_OF_SERVICE_ID