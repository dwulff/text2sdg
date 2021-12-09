# Detect Aurora SDG
detect_aurora = function(corpus, sdgs, verbose = FALSE){

  # select sdgs from simples
  aurora_simple = aurora_simple %>%
    dplyr::left_join(aurora_queries %>% dplyr::select(query, sdg), by = c("orig"="query")) %>%
    dplyr::filter(sdg %in% sdgs)

  # select sdgs from ws
  aurora_and = aurora_and %>%
    dplyr::left_join(aurora_queries %>% dplyr::select(query, sdg), by = c("orig"="query")) %>%
    dplyr::filter(sdg %in% sdgs)

  # select sdgs from ands
  aurora_w = aurora_w %>%
    dplyr::left_join(aurora_queries %>% dplyr::select(query, sdg), by = c("orig"="query")) %>%
    dplyr::filter(sdg %in% sdgs)

  # deal with SIMPLE
  simple_hits = search_corpus(corpus, aurora_simple$correct)
  simple_hits$query = aurora_simple$orig[as.numeric(stringr::str_extract(simple_hits$code, '[:digit:]+'))]

  # deal with AND
  and_hits_1 = search_corpus(corpus, aurora_and$correct)
  and_hits_2 = search_corpus(corpus, aurora_and$`correct 2`)
  if(nrow(and_hits_1) > 0 & nrow(and_hits_2) > 0){
    and_hits_1$part = "first"
    and_hits_2$part = "second"
    and_hits = and_hits_1 %>%
      dplyr::bind_rows(and_hits_2) %>%
      dplyr::group_by(code, doc_id) %>%
      dplyr::mutate(both = length(unique(part))==2) %>%
      dplyr::filter(both) %>%
      dplyr::ungroup() %>%
      dplyr::select(-part, -both)
    and_hits$query = aurora_and$orig[as.numeric(stringr::str_extract(and_hits$code, '[:digit:]+'))]
  } else {
    and_hits = simple_hits %>% dplyr::filter(rep(FALSE, nrow(simple_hits)))
  }

  # deal with W/
  w_hits_1 = search_corpus(corpus, aurora_w$correct)
  w_hits_2 = search_corpus(corpus, aurora_w$`correct 2`)
  w_hits_1$part = "first"
  w_hits_2$part = "second"
  w_hits = w_hits_1 %>%
    dplyr::bind_rows(w_hits_2) %>%
    dplyr::group_by(code, doc_id) %>%
    dplyr::mutate(both = length(unique(part))==2) %>%
    dplyr::filter(both)
  if(nrow(w_hits) > 0){
    w_hits%>%
      dplyr::group_by(code, doc_id) %>%
      dplyr::mutate(w3 = w_n(token_id[part == 'first'], token_id[part == 'second'])) %>%
      dplyr::filter(w3) %>%
      dplyr::ungroup() %>%
      dplyr::select(-part, -both, -w3)
    w_hits$query = aurora_w$orig[as.numeric(stringr::str_extract(w_hits$code, '[:digit:]+'))]
  } else {
    w_hits = simple_hits %>% dplyr::filter(rep(F, nrow(simple_hits)))
  }

  # handle special 1
  if("SDG-11" %in% sdgs){
    s1 = c("<(<physical> OR <sexual>) (<harass*>)>~3",
           "<victim*>",
           "(<city> OR <cities> OR <urban> OR <municipalit*>)")
    s1_hits = search_corpus(corpus, s1)
    s1_hits = s1_hits %>%
      dplyr::group_by(doc_id) %>%
      dplyr::filter(length(unique(code)) == 3) %>%
      dplyr::ungroup()
    if(nrow(s1_hits) > 0){
      s1_hits = s1_hits %>%
        dplyr::group_by(doc_id) %>%
        dplyr::filter(w_n(token_id[code == "query_1"], token_id[code == "query_2"]),
                      w_n(token_id[code == "query_3"], token_id[code %in% c("query_1","query_2")]))
    }
    s1_hits$query = '( "city"  OR  "cities"  OR  "urban"  OR  "municipalit*" )  W/3  ( ( "victim*" )  W/3  ( ( "physical"  OR  "sexual" )  W/3  ( "harass*" ) ) )'
  } else {
    s1_hits = simple_hits %>% dplyr::filter(rep(F, nrow(simple_hits)))
  }

  # handle special 2 & 3
  if("SDG-03" %in% sdgs){

    # handle special 2
    s2 = c("(<neonatal> OR <under-five> OR ( <(<under>) (<5> OR <five>)>~2 ) OR <before fifth>)",
           "(<mortality> OR <death*>)",
           "(<reduce> OR <end> OR <ending> OR <prevent*> OR <ratio*>)")
    s2_hits = search_corpus(corpus, s2)
    s2_hits = s2_hits %>%
      dplyr::group_by(doc_id) %>%
      dplyr::filter(length(unique(code)) == 3) %>%
      dplyr::ungroup()
    if(nrow(s2_hits) > 0){
      s2_hits = s2_hits %>%
        dplyr::group_by(doc_id) %>%
        dplyr::filter(w_n(token_id[code == "query_1"], token_id[code == "query_2"]),
                      w_n(token_id[code == "query_3"], token_id[code %in% c("query_1","query_2")]))
    }
    s2_hits$query = '( (\"reduce\" OR \"end\" OR \"ending\" OR \"prevent*\" OR \"ratio*\") W/3 ((\"neonatal\" OR \"under-five\" OR ( \"under\" W/2 (\"5\" OR \"five\") ) OR \"before fifth\") W/3 (\"mortality\" OR "death*") ) )'

    # handle special 3
    s3 = c("( <(<tobacco>) (<control*>)>~6 ) OR ( <(<health>) (<smoking>)>~3 )",
           "<(<smoking>) (<cessation> OR <quit*>)>~3",
           "<(<cessation> OR <quit*>) (<health> OR <benefit*>)>~3")
    s3_hits = search_corpus(corpus, s3)
    s3_hits = s3_hits %>%
      dplyr::group_by(doc_id) %>%
      dplyr::filter("query_1" %in% code || ("query_2" %in% code & "query_3" %in% code)) %>%
      dplyr::ungroup()
    s3_hits$query = '( \"tobacco\" W/6 \"control*\" ) OR ( \"health\" W/3 \"smoking\" ) OR ((\"smoking\") W/3 ("cessation\" OR \"quit*") W/3 ( \"health\"  OR  \"benefit*\" ))'


    } else {
    s2_hits = s3_hits = simple_hits %>% dplyr::filter(rep(F, nrow(simple_hits)))
  }


  # combine
  hits = simple_hits %>%
    dplyr::bind_rows(and_hits) %>%
    dplyr::bind_rows(w_hits) %>%
    dplyr::bind_rows(s1_hits) %>%
    dplyr::bind_rows(s2_hits) %>%
    dplyr::bind_rows(s3_hits) %>%
    dplyr::select(-sentence) %>%
    dplyr::mutate(document = as.numeric(as.character(doc_id)),
                  feature = as.character(feature)) %>%
    dplyr::arrange(document)

  # out

  if(nrow(hits) == 0) return(NULL)

  hits %>%
    dplyr::left_join(aurora_queries, by="query") %>%
    dplyr::mutate(system = "Aurora") %>%
    dplyr::select(-sdg_title, -sdg_description)  %>%
    dplyr::group_by(document, query_id) %>%
    #paste features together
    dplyr::summarise(matches = dplyr::n(),
                     features = toString(feature),
                     dplyr::across(c(sdg, system), unique)) %>%
    dplyr::ungroup() %>%
    #add hit id
    dplyr::mutate(hit = 1:nrow(.)) %>%
    dplyr::select(document, sdg, system, query_id, features, hit)

  }
