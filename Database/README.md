## RDS (Mysql)
Database로 AWS RDS 를 사용합니다. RDS 는 완전관리형 데이터베이스 서비스입니다. 각 AZ와 DB 서브넷그룹에서 "Master" , "Slave" 구조를 적용합니다. MYSQL 포트인 3306과 애플리케이션 계층에 ELB를 넘어온 트래픽을 보안그룹에 적용합니다. 

---
