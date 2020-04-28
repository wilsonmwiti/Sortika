import * as functions from 'firebase-functions'
import * as superadmin from 'firebase-admin'
//import * as express from 'express'
//import * as bodyParser from "body-parser"
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore'
//import * as auth from './authentication'

// //Initialize Express Server
// const app = express()
// const main = express()

// /*
// SERVER CONFIGURATION
// 1) Base Path
// 2) Set JSON as main parser
// */
// main.use('/api/v1', app)
// main.use(bodyParser.json())

// /*
// API
// */
// //Registration
// export const sortikaMain = functions.https.onRequest(main)
// app.post('/users', auth.createUser)

/*
DATABASE
*/
//Calculate goal allocations
superadmin.initializeApp();
const db = superadmin.firestore(); 

exports.allocationsCalculator = functions.firestore
    .document('/users/{user}/goals/{goal}')
    .onCreate(async (data, context) => {
        //Retrieve user id
        var uid = ''
        if (data.get('uid') === null) {
            uid = data.get('uid')
            console.log(uid)
        }
        else {
            uid = data.get('uid')
            console.log(uid)
        }
        const docs = await db.collection('users').doc(uid).collection('goals').get()
        const allDocs: Array<DocumentSnapshot> = docs.docs
        //Periods placeholder
        const periods: Array<number> = []
        const amounts: Array<number> = []
        const adjustedAmounts: Array<number> = []
        const documentIds: Array<string> = []
        const allocationpercents: Array<number> = []
        allDocs.forEach(element => {
            //Document Snapshot
            /*
            Timestamp is returned from Firebase.
            Convert to Date then get differences in days
            */
            const timeStart: FirebaseFirestore.Timestamp = element.get('goalCreateDate')
            const dateStart: Date = timeStart.toDate()

            const timeEnd: FirebaseFirestore.Timestamp = element.get('goalEndDate')
            const dateEnd = timeEnd.toDate()

            const differenceSeconds = dateEnd.getTime() - dateStart.getTime()
            const differenceDays = differenceSeconds / (1000*60*60*24)

            //Save the difference in a list
            periods.push(Math.floor(differenceDays))
            //Retrieve target amount and save in amounts
            amounts.push(element.get('goalAmount'))
            documentIds.push(element.id)

        });
        //Sort from smallest to largest
        periods.sort()
        const leastDays = periods[0]
        //Show arrays
        console.log(`Periods: ${periods}`)
        console.log(`Amounts: ${amounts}`)
        console.log(`Document Ids: ${documentIds}`)
        //Keep a total adjusted amount counter
        var totalAdjusted: number = 0
        for (let index = 0; index < amounts.length; index ++) {
            var adjusted: number = ( (amounts[index] * leastDays) / periods[index] )
            adjustedAmounts.push(adjusted)
            totalAdjusted = totalAdjusted + adjusted
        }
        //Show adjusted amounts
        console.log(`Adjusted Amounts: ${adjustedAmounts}`)
        //Show the total adjusted number
        console.log(`Total Adjusted Value: ${totalAdjusted}`)
        //Get allocation percentages
        for (let index = 0; index < adjustedAmounts.length; index ++) {
            var percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
            allocationpercents.push(percent)
        }
        //Show percents
        //Show the total adjusted number
        console.log(`Allocation Percents: ${allocationpercents}`)
        //Update each document with new allocations
        for (let index = 0; index < documentIds.length; index ++) {
            await db.collection('users').doc(uid)
                .collection('goals').doc(documentIds[index]).update({'goalAllocation':allocationpercents[index]})
        }
        //Update User Targets
        const dailyTarget: number = (totalAdjusted / 365)
        const weeklyTarget: number = (dailyTarget * 7)
        const monthlyTarget: number = (dailyTarget * 30)
        //Update USERS Collection
        await db.collection('users').doc(uid).update({
            'dailyTarget': dailyTarget,
            'weeklyTarget': weeklyTarget,
            'monthlyTarget': monthlyTarget
        })
    })

