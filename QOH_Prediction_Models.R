
{
    
rm(list=ls())
Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre1.8.0_121')  
set.seed(100)
suppressWarnings(library(dummies))
suppressWarnings(library(e1071))
suppressWarnings(library(RJDBC))

# Regression Analysis
# Regression models are crested with current employee data. These models are used to analyze the candidates.
# Several models are created with diffirent variable groups and different Data Science methods are used
#to improve the models. Finally ensembling is used to get the end results.
{
    #Getting Started with Analysis
    {
        #read  data
        jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="C:/Oracle/Ora11gR2/jdbc/lib/ojdbc6.jar")
        jdbcConnection <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@//129.144.51.94:1521/____._____.____", "username", "password") 
        Candidate_data <- dbGetQuery(jdbcConnection, "SELECT * FROM CANDIDATE_DATA")
        Past_Candidate_data <- dbGetQuery(jdbcConnection, "SELECT * FROM PAST_CANDIDATE_DATA")
        Succession_data <- dbGetQuery(jdbcConnection, "SELECT * FROM PLAN_DETAILS")
        Plan_ID <- Succession_data$PLAN_ID[2]
        Job_ID <- Succession_data$PER_JOBS_NAME[2]
        
        #Coverting required Charachter Fields to numeric
        {
            Past_Candidate_data$NW_CENTRALITY_IMP <- as.numeric(Past_Candidate_data$NW_CENTRALITY_IMP)
            Past_Candidate_data$CLIENT_FOCUS <- as.numeric(Past_Candidate_data$CLIENT_FOCUS)
            Past_Candidate_data$LEADERSHIP <- as.numeric(Past_Candidate_data$LEADERSHIP)
            Past_Candidate_data$INNOVATION <- as.numeric(Past_Candidate_data$INNOVATION)
            Past_Candidate_data$STRAT_THINKIN <- as.numeric(Past_Candidate_data$STRAT_THINKIN)
            Past_Candidate_data$RSLT_ORIENT <- as.numeric(Past_Candidate_data$RSLT_ORIENT)
            Past_Candidate_data$ENTREPRENEURIAL <- as.numeric(Past_Candidate_data$ENTREPRENEURIAL)
            Past_Candidate_data$COMM_SKILLS <- as.numeric(Past_Candidate_data$COMM_SKILLS)
            Past_Candidate_data$BUS_KNWLDG <- as.numeric(Past_Candidate_data$BUS_KNWLDG)
            Past_Candidate_data$ANALYTIC_SKILLS <- as.numeric(Past_Candidate_data$ANALYTIC_SKILLS)
            Past_Candidate_data$PROJ_MNGMNT <- as.numeric(Past_Candidate_data$PROJ_MNGMNT)
            Past_Candidate_data$EMPLOYEE_POTENTIAL <- as.numeric(Past_Candidate_data$EMPLOYEE_POTENTIAL)
            Past_Candidate_data$IS_INTERNAL <- as.numeric(Past_Candidate_data$IS_INTERNAL)
            
            
            Candidate_data$NW_CENTRALITY_IMP <- as.numeric(Candidate_data$NW_CENTRALITY_IMP)
            Candidate_data$CLIENT_FOCUS <- as.numeric(Candidate_data$CLIENT_FOCUS)
            Candidate_data$LEADERSHIP <- as.numeric(Candidate_data$LEADERSHIP)
            Candidate_data$INNOVATION <- as.numeric(Candidate_data$INNOVATION)
            Candidate_data$STRAT_THINKIN <- as.numeric(Candidate_data$STRAT_THINKIN)
            Candidate_data$RSLT_ORIENT <- as.numeric(Candidate_data$RSLT_ORIENT)
            Candidate_data$ENTREPRENEURIAL <- as.numeric(Candidate_data$ENTREPRENEURIAL)
            Candidate_data$COMM_SKILLS <- as.numeric(Candidate_data$COMM_SKILLS)
            Candidate_data$BUS_KNWLDG <- as.numeric(Candidate_data$BUS_KNWLDG)
            Candidate_data$ANALYTIC_SKILLS <- as.numeric(Candidate_data$ANALYTIC_SKILLS)
            Candidate_data$PROJ_MNGMNT <- as.numeric(Candidate_data$PROJ_MNGMNT)
            Candidate_data$EMPLOYEE_POTENTIAL <- as.numeric(Candidate_data$EMPLOYEE_POTENTIAL)
        }
        Candidate_data <- Candidate_data[which(Candidate_data$CUR_DESG == Job_ID & Candidate_data$SUCCESSION_PLAN_ID == Plan_ID),]
        Past_Candidate_data1 <- Past_Candidate_data[which(Past_Candidate_data$CUR_DESIG == Job_ID & Past_Candidate_data$IS_INTERNAL == 1),]
        
        #Drop columns that are not relevant for analysis
        
        drop_colsC <- c("ID", "TRANSACTION_ID", "SUCCESSION_PLAN_ID", "CAND_ID", "CAND_NAME",
                        "LOCATION", "CUR_DESG",  "SOURC_CHANNEL", "RESUME_URL", "LINKEDIN_NW_SIZE",
                        "CAND_REVW", "JOIN_PRED", "CTC", "RELOCATION_COST", "JOINING_BONUS", "HIR_COST", 
                        "TRN_COST", "CREATED_BY", "CREATED_ON", "UPDATED_BY", "UPDATED_ON")
        drop_colsPC <- c("CAND_ID", "CAND_NAME", "LOCATION", "CUR_DESIG", "SOURC_CHANNEL", "RESUME_URL", 
                         "CAND_REVW", "CTC", "RELOCATION_COST", "JOINING_BONUS", "HIR_COST", "TRN_COST", 
                         "LINKEDIN_NW_SIZE", "CREATED_BY", "CREATED_ON", "UPDATED_BY", "UPDATED_ON", "IS_INTERNAL")
        pcnd_data_new <- Past_Candidate_data1[, ! names(Past_Candidate_data1) %in% drop_colsPC, drop = F]
        cnd_data_new <- Candidate_data[, ! names(Candidate_data) %in% drop_colsC, drop = F]
        
        data_for_prediction <- cnd_data_new
        candidate_prediction <- data.frame(matrix(0,nrow = dim(data_for_prediction),ncol = 3))
        colnames(candidate_prediction) <- c("Model_1", "Model_2","Final_Value")
    }
    
    #Model_1: Boosting is used
    {
        pcnd_data_new_train<-pcnd_data_new
        
        #Regression Analysis to create linear models
        stats_model_1 <- data.frame("R_Squared" = 0)
        {
            #Regression based on skills
            {
                fit_skills <- step(lm(EMPLOYEE_POTENTIAL ~ BUS_KNWLDG + PROJ_MNGMNT + ANALYTIC_SKILLS +
                                COMM_SKILLS, data=pcnd_data_new_train), direction = "both", trace = FALSE)
            }
            
            #Regression based on competency
            {
                fit_competency <- step(lm(EMPLOYEE_POTENTIAL ~ CLIENT_FOCUS + LEADERSHIP + INNOVATION + 
                                    STRAT_THINKIN + RSLT_ORIENT + ENTREPRENEURIAL, 
                                    data=pcnd_data_new_train), direction = "both", trace = FALSE)
            }
            
            #Regression based on Education
            {
                fit_education <- step(lm(EMPLOYEE_POTENTIAL ~ ACAD_PERF + EDU_LEVEL + CERTIFICATIONS, 
                                         data = pcnd_data_new_train), direction = "both", trace = FALSE)
            }
            
            
            #Regression based on Other Features
            {
                fit_other <- step(lm(EMPLOYEE_POTENTIAL ~ TOT_YRS_OF_EXP + TOT_YRS_LAST_COMP1 + TOT_YRS_LAST_COMP2 + 
                                INCEN_RATIO + IS_FORMER_EMP + NW_CENTRALITY_IMP + WILLIN_TO_TRAVEL, data = pcnd_data_new_train), direction = "both", trace = FALSE)
            }
            
        }
        stats_model_1[1,1]<-summary(fit_skills)$r.squared
        stats_model_1[2,1]<-summary(fit_competency)$r.squared
        stats_model_1[3,1]<-summary(fit_education)$r.squared
        stats_model_1[4,1]<-summary(fit_other)$r.squared
        
        #Prediction using linear models
        {
            #Predicting test set values
            test_predictedM1 = data.frame("fit_skills" = predict(fit_skills, data_for_prediction), 
                                          "fit_competency" = predict(fit_competency, data_for_prediction),
                                          "fit_education" = predict(fit_education, data_for_prediction),
                                          "fit_other" = predict(fit_other, data_for_prediction))#passing candidate data for which we need the prediction
            
            
            #Ensembled average prediction
            test_predictedM1$ensembled = (stats_model_1$R_Squared[1]*test_predictedM1$fit_skills + 
                                              stats_model_1$R_Squared[2]*test_predictedM1$fit_competency + 
                                              stats_model_1$R_Squared[3]*test_predictedM1$fit_education + 
                                              stats_model_1$R_Squared[4]*test_predictedM1$fit_other)/sum(stats_model_1$R_Squared)
        }
        
        
        #Gradient Boosting on Ensembled model
        pred <- (predict(fit_skills) + predict(fit_competency) + predict(fit_education) + predict(fit_other))/4
        actual <- as.numeric(pcnd_data_new_train$EMPLOYEE_POTENTIAL)
        fit_e1 <- list()
        for (i in 1:2)
        {   
            e1 <- actual - pred
            fit_e1[[i]] <- step(lm(e1~.,data = subset(pcnd_data_new_train, select=-c(EMPLOYEE_POTENTIAL))), 
                                direction = "both", trace = FALSE)
            actual <- e1
            pred <- predict(fit_e1[[i]], pcnd_data_new_train)
            test_predictedM1$ensembled<- test_predictedM1$ensembled + predict(fit_e1[[i]], data_for_prediction)
        }
        
        #Predicted Values for Candidate Data from Model_1
        candidate_prediction$Model_1 <- test_predictedM1$ensembled
    }
    
    #Model_2: Bagging is used
    {
        #Regression Analysis to create linear models
        run = 10
        stats_model_2 <- data.frame("R_Squared" = 0)
        
        #Regression with Bagging
        pcnd_data_new_train<-pcnd_data_new[sample(nrow(pcnd_data_new), 0.5*dim(pcnd_data_new)[1]), , drop = FALSE]
        
        #Regression on all variables 
        fit_complete <- step(lm(EMPLOYEE_POTENTIAL ~ ., data = subset(pcnd_data_new_train)), direction="backward", trace = FALSE)
        stats_model_2[1,1] <- summary(fit_complete)$r.squared
        test_predictedM2 <- data.frame(predict(fit_complete, data_for_prediction))
        for(r in 1:run-1)
        {   
            pcnd_data_new_train<-pcnd_data_new[sample(nrow(pcnd_data_new), 0.5*dim(pcnd_data_new)[1]), , drop = FALSE]
            
            #Regression on all variables 
            fit_complete <- step(lm(EMPLOYEE_POTENTIAL ~ ., data = subset(pcnd_data_new_train)), 
                                 direction="backward", trace = FALSE)
            stats_model_2[r+1,1] <- summary(fit_complete)$r.squared
            #Prediction test set values using linear models & candidates
            test_predictedM2 <- cbind(test_predictedM2, (predict(fit_complete, data_for_prediction)))
        }
        
        colnames(test_predictedM2) <- c(paste("model_", 1:(run+1), sep = ""))
        
        #Ensembled average prediction
        test_predictedM2$ensembled <- 0
        for(i in 1:dim(test_predictedM2)[1])
        {   for(r in 1:run)
            {   test_predictedM2$ensembled[i] <- test_predictedM2$ensembled[i] + test_predictedM2[i,r]
            }
        }
        test_predictedM2$ensembled <- test_predictedM2$ensembled/run
        
        #Predicted Values for Candidate Data from Model_1
        candidate_prediction$Model_2 <- test_predictedM2$ensembled
    }
    
    #Final Prediction
    {   
        #Ensembled Model_1 and Model_2
        candidate_prediction$Final_Value <- (candidate_prediction$Model_1 + candidate_prediction$Model_2)/2
        
        #Preformance Review
        {
            Candidate_data$EMPLOYEE_POTENTIAL = round(candidate_prediction$Final_Value, digits = 0)
            for(i in 1:dim(candidate_prediction)[1])
            {   
                if(candidate_prediction$Final_Value[i] <= 65.5)
                {   Candidate_data$CAND_REVW[i] = "Average"
                } else if(candidate_prediction$Final_Value[i] >= 80.5)
                {   Candidate_data$CAND_REVW[i] = "Top"
                } else
                {   Candidate_data$CAND_REVW[i] = "Good"
                }
            }
            Candidate_data$CAND_REVW <- factor(Candidate_data$CAND_REVW)
            print("Prediction: Successful")
        }
    }
}


#Joining Prediction
#SVM is used to predict the probability of joining. Bagging is used to reduce the variance.
{
    #Getting Started with Analysis
    {
        #Read the data and Drop columns that are not relevant for analysis
        Past_Candidate_data2 <- Past_Candidate_data[which(Past_Candidate_data$CUR_DESIG == Job_ID),]
        
        drop_colsC <- c( "ID", "TRANSACTION_ID", "SUCCESSION_PLAN_ID", "CAND_ID", "CAND_NAME",
                       "LOCATION", "CUR_DESG",  "SOURC_CHANNEL", "RESUME_URL", "LINKEDIN_NW_SIZE",
                       "CAND_REVW", "JOIN_PRED", "CTC", "RELOCATION_COST", "JOINING_BONUS", "HIR_COST", 
                       "TRN_COST", "CREATED_BY", "CREATED_ON", "UPDATED_BY", "UPDATED_ON")
        drop_colsPC <- c("CAND_ID", "CAND_NAME", "LOCATION", "CUR_DESIG", "SOURC_CHANNEL", "RESUME_URL", 
                         "CAND_REVW", "CTC", "RELOCATION_COST", "JOINING_BONUS", "HIR_COST", "TRN_COST", 
                         "LINKEDIN_NW_SIZE", "CREATED_BY", "CREATED_ON", "UPDATED_BY", "UPDATED_ON")
        pcnd_data_new <- Past_Candidate_data2[, ! names(Past_Candidate_data2) %in% drop_colsPC, drop = F]
        cnd_data_new <- Candidate_data[, ! names(Candidate_data) %in% drop_colsC, drop = F]
        #Creating dummy variable for categorical fields
        pcnd_data_new <- dummy.data.frame(pcnd_data_new, sep = "_")
        cnd_data_new <- dummy.data.frame(cnd_data_new, sep = "_")
    }  

    #Predition Model Training
    {
        pcnd_data_new_train <- pcnd_data_new[sample(nrow(pcnd_data_new), 0.7*dim(pcnd_data_new)[1]), , drop = FALSE]
    
        #SVM Model
        model_svm <- svm(IS_INTERNAL ~ ., data = pcnd_data_new_train, gamma = 0.1)
        pred <- data.frame(predict(model_svm, cnd_data_new))
    
        for(i in 1:5) 
        {   
            pcnd_data_new_train <- pcnd_data_new[sample(nrow(pcnd_data_new), 0.7*dim(pcnd_data_new)[1]), , drop = FALSE]
            #SVM Model
            model_svm <- svm(IS_INTERNAL ~ ., pcnd_data_new_train, gamma = 0.1)
            pred <- cbind(pred, predict(model_svm, cnd_data_new))
        }
    }

    #Updating to Candidate_data
    {   
        pred <-data.frame("Fit" = round(rowMeans(pred), digits = 2)*100)
        Candidate_data$JOIN_PRED <- pred$Fit
        print("Prediction: Successful")
    }
}


# Write to Table
{   
    print("Updating values to the database")
    for (i in 1:dim(Candidate_data)[1])
    { 
        #remember to convert the variable type if required 
        EMP_POT <- as.character(Candidate_data$EMPLOYEE_POTENTIAL[i])
        CND_REV <- Candidate_data$CAND_REVW[i]
        join_pred1 <- Candidate_data$JOIN_PRED[i]
        cand_id1 <- Candidate_data$CAND_ID[i]
        CND_REV <- paste("'",CND_REV,"'", sep = "")
        cand_id1 <- paste("'",cand_id1,"'", sep = "")
        testupdate <- paste("Update TAB_QOH_CANDIDATE_DATA set JOIN_PRED=",join_pred1,",CAND_REVW=",CND_REV,",EMPLOYEE_POTENTIAL=",EMP_POT," where CAND_ID=",cand_id1)
        dbSendUpdate(jdbcConnection, testupdate)
    }
    print("Update successful")
}

}
